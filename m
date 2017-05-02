From: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Tue, 2 May 2017 18:39:20 +0000
Message-ID: <1493750358.2552.13.camel@sandisk.com>
References: <20170501163311.GA22209@lst.de>
         <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d9214af6-1c6f-9f95-fc00-3e4a316b4f81-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Language: en-US
Content-ID: <E901171F32AAB047A577AAEB1A2B0BB3-+cFlbfsKLD6cE4WynfumptQqCkab/8FMAL8bYrjMMd8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-05-02 at 14:25 +0200, Ursula Braun wrote:
> if you can point out specific issues, we will be happy to work with you
> to get them addressed!

Hello Ursula,

My list of issues that I would like to see addressed can be found below. Do=
ug,
Christoph and others may have additional inputs. The issues that have not y=
et
been mentioned in other e-mails are:
- The SMC driver only supports one RDMA transport type (RoCE v1) but
=A0 none of the other RDMA transport types (RoCE v2, IB and iWARP). New
=A0 RDMA drivers should support all RDMA transport types transparently.
  The traditional approach to support multiple RDMA transport types is
  by using the RDMA/CM to establish connections.
- The implementation of the SMC driver only supports RoCEv1. This is
=A0 a very unfortunate choice because:
=A0 - RoCEv1 is not routable and hence is limited to a single Ethernet
=A0=A0=A0=A0broadcast domain.
=A0 - RoCEv1 packets escape a whole bunch of mechanisms that only work
=A0=A0=A0=A0for IP packets. Firewalls pass all RoCEv1 packets and switches
=A0=A0=A0=A0do not restrict RoCEv1 packets to a single VLAN. This means tha=
t
=A0=A0=A0=A0if the network configuration is changed after an SMC connection
=A0=A0=A0=A0has been set up such that IP communication between the endpoint=
s
=A0=A0=A0=A0of an SMC connection is blocked that the SMC RoCEv1 packets wil=
l
    not be blocked by the network equipment of which the configuration
=A0=A0=A0=A0has just been changed.
- As already mentioned by Christoph, the SMC implementation uses RDMA
  calls that probably will be deprecated soon (ib_create_cq()) and
  should use the RDMA R/W API instead of building sge lists itself.

Bart.=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
