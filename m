From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [patch] add tcp congestion control relevant parts
Date: Wed, 2 Jan 2008 09:40:43 -0800
Message-ID: <20080102094043.590a94d7@deepthought>
References: <476000E7.4060104@secunet.com>
	<47624360.5050007@gmail.com>
	<20071214081540.4596bf21@deepthought>
	<477B5F89.9000707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-net-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Thomas Egerer <thomas.Egerer-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Kerrisk <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <477B5F89.9000707-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 02 Jan 2008 10:55:21 +0100
Michael Kerrisk <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:

> 
> 
> Stephen Hemminger wrote:
> > On Fri, 14 Dec 2007 09:48:32 +0100
> > Michael Kerrisk <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:
> > 
> >> Hello Linux networking folk,
> >>
> >> I received the patch below for the tcp.7 man page.  Would anybody here be
> >> prepared to review the new material / double check the details?
> >>
> >> Cheers,
> >>
> >> Michael
> >>
> >> -------- Original Message --------
> >> Subject: [patch] add tcp congestion control relevant parts
> >> Date: Wed, 12 Dec 2007 16:40:23 +0100
> >> From: Thomas Egerer <thomas.Egerer-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
> >> To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> >> CC: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >>
> >> Hello *,
> >>
> >> man-pages version : 2.70 from http://www.kernel.org/pub/linux/docs/man-pages/
> >> All required information were obtained by reading the kernel
> >> code/documentation.
> >> I'm not sure, whether it is completely bullet proof on when the sysctl
> >> variables/socket option first appeared in the kernel, so you might as well
> >> drop this information, but I'm pretty sure about how it works.
> >> Here we go with my patch:
> >>
> >> diff -ru man-pages-2.70/man7/tcp.7 man-pages-2.70.new/man7/tcp.7
> >> --- man-pages-2.70/man7/tcp.7   2007-11-24 14:33:34.000000000 +0100
> >> +++ man-pages-2.70.new/man7/tcp.7       2007-12-12 16:34:52.000000000 +0100
> >> @@ -177,8 +177,6 @@
> >>  .\" FIXME As at Sept 2006, kernel 2.6.18-rc5, the following are
> >>  .\"    not yet documented (shown with default values):
> >>  .\"
> >> -.\"     /proc/sys/net/ipv4/tcp_congestion_control (since 2.6.13)
> >> -.\"     bic
> >>  .\"     /proc/sys/net/ipv4/tcp_moderate_rcvbuf
> >>  .\"     1
> >>  .\"     /proc/sys/net/ipv4/tcp_no_metrics_save
> >> @@ -224,6 +222,20 @@
> >>  are reserved for the application buffer.
> >>  A value of 0
> >>  implies that no amount is reserved.
> >> +.TP
> >> +.BR tcp_allowed_congestion_control \
> >> +" (String; default: cubic reno) (since 2.6.13) "
> >> +Show/set the congestion control choices available to non-privileged
> >> +processes. The list is a subset of those listed in
> >> +.IR tcp_available_congestion_control "."
> >> +Default is "cubic reno" and the default setting
> >> +.RI ( tcp_congestion_control ).
> >> +.TP
> >> +.BR tcp_available_congestion_control \
> >> +" (String; default: cubic reno) (since 2.6.13) "
> >> +Lists the TCP congestion control algorithms available on the system. This
> >> value
> >> +can only be changed by loading/unloading modules responsible for congestion
> >> +control.
> >>  .\"
> >>  .\" The following is from 2.6.12: Documentation/networking/ip-sysctl.txt
> >>  .TP
> >> @@ -257,6 +269,17 @@
> >>  Allows two flows sharing the same connection to converge
> >>  more rapidly.
> >>  .TP
> >> +.BR tcp_congestion_control " (String; default: cubic reno) (since 2.6.13) "
> >> +Determines the congestion control algorithm used for newly created TCP
> >> +sockets. By default Linux uses cubic with reno as fallback. If you want
> >> +to have more control over the algorithm used, you must enable the symbol
> >> +CONFIG_TCP_CONG_ADVANCED in your kernel config.
> > 
> > You can choose the default congestion control as well as part of the kernel
> > configuration.
> 
> Hi Stephen,
> 
> Other than this, did the doc patch look okay?  (I'm not sure whether there
> was an implied ACK in your message for the rest of the patch.)
> 
> Cheers,
> 
> Michael
> 

Yes, and having this documented will hopefully help answer people's
questions.

-- 
Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
-
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
