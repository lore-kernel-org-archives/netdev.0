From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/IPoIB: Check the headroom size
Date: Wed, 26 Apr 2017 09:50:38 -0400
Message-ID: <1493214638.3041.110.camel@redhat.com>
References: <CAJ3xEMg4_2ph7QwPsUb-tX-K4d2ppkqz98sPzytsmBCK=29WHw@mail.gmail.com>
         <CAAk-MO8O19iC2Yn-BMn5pKTAYxaSzGPMyta=fwes3XSvzmz_cQ@mail.gmail.com>
         <CAJ3xEMgw=9sj3rdahPEiST_yDfDJPNSZZLRn43tnb3bK4_RPzg@mail.gmail.com>
         <CAAk-MO-B8Liv6RyGye_Fx-9OELCUrGMj5SwK9UsciC=khSO5fA@mail.gmail.com>
         <CAJ3xEMgwS1Bq8+eZC1iAr6xi8ZPHrchsOJ5r4LNJxR8P+6VipA@mail.gmail.com>
         <1493134815.3041.72.camel@redhat.com>
         <CAJ3xEMjqkJrKi+6ronuPBn2P6y8p6sdhVppDzFtMwQrhL13bzg@mail.gmail.com>
         <1493192794.2409.3.camel@redhat.com>
         <20170426125230.GB19179@dhcp-13-42.nay.redhat.com>
         <1493213258.3041.98.camel@redhat.com>
         <20170426133353.GA7898@dhcp-13-42.nay.redhat.com>
         <1493214483.3041.108.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1493214483.3041.108.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-04-26 at 09:48 -0400, Doug Ledford wrote:
> On Wed, 2017-04-26 at 21:33 +0800, Honggang LI wrote:
> > 
> > Yes, it is during the process of removing the final slave. The
> > reproducer looks like this:
> > 
> > ping remote_ip_over_bonding_interface &
> > while 1; do
> > 	ifdown bond0
> > 	ifup   bond0
> > done

BTW, rerunning your test as:

ping remote_ip_over_bonding_interface &
while 1; do
    echo -n "Downing interface..."
    ifdown bond0
    echo "done."
    sleep 1
    echo -n "Bringing interface up..."
    ifup bond0
    echo "done."
done

will allow you to more precisely identify whether the failure is during
the down or the up of the interface.

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
