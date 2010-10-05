From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH] SIW: Module initialization
Date: Tue, 5 Oct 2010 15:12:48 +0200
Message-ID: <OFFB26426A.EB2C13FD-ONC12577B3.00488392-C12577B3.004895E4@ch.ibm.com>
References: <1286261640-5121-1-git-send-email-bmt@zurich.ibm.com> <AANLkTik5=i+A5_OpU0rVyfYi=ibgS9UWMu82vMCmM=PN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTik5=i+A5_OpU0rVyfYi=ibgS9UWMu82vMCmM=PN-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote on 10/05/2010 12:57:21 PM:

> Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org> 
> Sent by: bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> 
> 10/05/2010 12:57 PM 
> 
> To 
> 
> Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> 
> 
> cc 
> 
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org 
> 
> Subject 
> 
> Re: [PATCH] SIW: Module initialization 
> 
> On Tue, Oct 5, 2010 at 8:54 AM, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> 
wrote:
> > +static int loopback_enabled;
> > +module_param(loopback_enabled, int, 0644);
> > +MODULE_PARM_DESC(loopback_enabled, "enable_loopback");
> 
> A minor comment: since kernel 2.6.31 the type "bool" can be used for
> boolean kernel module parameters.
> 
oh, thanks. there are currently two more occurrences (MPA crc, 0copy 
transmit). 
it will be changed accordingly. 

> > + * TODO: Dynamic device management (network device 
registration/removal).
> 
> The current implementation is such that one siw device is created for
> each network device found at kernel module load time. That means that
> you force the user to load the siw kernel module after all other
> kernel modules that register a network device. I'm not sure that's a
> good idea.
> 
good point. do you have a suggestion here - would you like to see 
siw to be enabled more selectively? 
iwarp is a protocol on top of TCP, explicitly defining the 
semantics of data fetching and placement. end-to-end connectivity 
and efficient data shipping is provided by TCP/IP. not taking into 
account dedicated RDMA hardware, any TCP stream may carry iwarp 
traffic. from that point of view, binding a software based 
rdma stack to dedicated devices is a concession to the 
given environment, in particular to the given rdma 
connection management. therefore, we started with binding to all 
available network devices. 


> > +                       if (!siw_device) {
> > +                               siw_device = siw_p;
> > +                               siw_p->next = NULL;
> > +                       } else {
> > +                               siw_p->next = siw_device->next;
> > +                               siw_device->next = siw_p;
> > +                       }
> 
> Why a custom linked list implementation instead of using <linux/list.h> 
?
> 
i agree. will be changed. 

Bernard.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
