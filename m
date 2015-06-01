From: vaibhavkhanduja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: Re: [RFC PATCH 0/4] Make iSCSI network namespace aware
Date: Sun, 31 May 2015 20:43:57 -0700 (PDT)
Message-ID: <6c292826-4217-4e9e-aab4-4451a1460c3f@googlegroups.com>
References: <1431555167-23995-1-git-send-email-cleech@redhat.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_279_1560941177.1433130237684"
Cc: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <open-iscsi+bncBD65NQGTVQGBBWGPW6VQKGQEPC5YS7A-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1431555167-23995-1-git-send-email-cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

------=_Part_279_1560941177.1433130237684
Content-Type: multipart/alternative;
	boundary="----=_Part_280_1078130087.1433130237684"

------=_Part_280_1078130087.1433130237684
Content-Type: text/plain; charset=UTF-8

Are there any plans to get it upstream? if yes which kernel version?

On Wednesday, May 13, 2015 at 3:13:18 PM UTC-7, Chris Leech wrote:
>
> I've had a few reports of people trying to run iscsid in a container, 
> which 
> doesn't work at all when using network namespaces.  This is the start of 
> me 
> looking at what it would take to make that work, and if it makes sense at 
> all. 
>
> The first issue is that the kernel side of the iSCSI netlink control 
> protocol 
> only operates in the initial network namespace.  But beyond that, if we 
> allow 
> iSCSI to be managed within a namespace we need to decide what that means. 
>  I 
> think it makes the most sense to isolate the iSCSI host, along with it's 
> associated endpoints, connections, and sessions, to a network namespace 
> and 
> allow multiple instances of the userspace tools to exist in separate 
> namespaces 
> managing separate hosts. 
>
> It works well for iscsi_tcp, which creates a host per session.  There's no 
> attempt to manage sessions on offloading hosts independently, although 
> future 
> work could include the ability to move an entire host to a new namespace 
> like 
> is supported for network devices. 
>
> This is only about the structures and functionality involved in 
> maintaining the 
> iSCSI session, the SCSI host along with it's discovered targets and 
> devices has 
> no association with network namespaces. 
>
> These patches are functional, but not complete.  There's no isolation 
> enforced 
> in the kernel just yet, so it relies on well behaved userspace.  I plan on 
> fixing that, but wanted some feedback on the idea and approach so far. 
>
> Thanks, 
>         Chris 
>
> Chris Leech (4): 
>   iscsi: create per-net iscsi nl kernel sockets 
>   iscsi: sysfs filtering by network namespace 
>   iscsi: make all netlink multicast namespace aware 
>   iscsi: set netns for iscsi_tcp hosts 
>
>  drivers/scsi/iscsi_tcp.c            |   7 + 
>  drivers/scsi/scsi_transport_iscsi.c | 264 
> +++++++++++++++++++++++++++++------- 
>  include/scsi/scsi_transport_iscsi.h |   2 + 
>  3 files changed, 222 insertions(+), 51 deletions(-) 
>
> -- 
> 2.1.0 
>
>

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at http://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.

------=_Part_280_1078130087.1433130237684
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Are there any plans to get it upstream? if yes which kerne=
l version?<br><br>On Wednesday, May 13, 2015 at 3:13:18 PM UTC-7, Chris Lee=
ch wrote:<blockquote class=3D"gmail_quote" style=3D"margin: 0;margin-left: =
0.8ex;border-left: 1px #ccc solid;padding-left: 1ex;">I've had a few report=
s of people trying to run iscsid in a container, which
<br>doesn't work at all when using network namespaces. &nbsp;This is the st=
art of me
<br>looking at what it would take to make that work, and if it makes sense =
at all.
<br>
<br>The first issue is that the kernel side of the iSCSI netlink control pr=
otocol
<br>only operates in the initial network namespace. &nbsp;But beyond that, =
if we allow
<br>iSCSI to be managed within a namespace we need to decide what that mean=
s. &nbsp;I
<br>think it makes the most sense to isolate the iSCSI host, along with it'=
s
<br>associated endpoints, connections, and sessions, to a network namespace=
 and
<br>allow multiple instances of the userspace tools to exist in separate na=
mespaces
<br>managing separate hosts.
<br>
<br>It works well for iscsi_tcp, which creates a host per session. &nbsp;Th=
ere's no
<br>attempt to manage sessions on offloading hosts independently, although =
future
<br>work could include the ability to move an entire host to a new namespac=
e like
<br>is supported for network devices.
<br>
<br>This is only about the structures and functionality involved in maintai=
ning the
<br>iSCSI session, the SCSI host along with it's discovered targets and dev=
ices has
<br>no association with network namespaces.
<br>
<br>These patches are functional, but not complete. &nbsp;There's no isolat=
ion enforced
<br>in the kernel just yet, so it relies on well behaved userspace. &nbsp;I=
 plan on
<br>fixing that, but wanted some feedback on the idea and approach so far.
<br>
<br>Thanks,
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Chris
<br>
<br>Chris Leech (4):
<br>&nbsp; iscsi: create per-net iscsi nl kernel sockets
<br>&nbsp; iscsi: sysfs filtering by network namespace
<br>&nbsp; iscsi: make all netlink multicast namespace aware
<br>&nbsp; iscsi: set netns for iscsi_tcp hosts
<br>
<br>&nbsp;drivers/scsi/iscsi_tcp.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
;| &nbsp; 7 +
<br>&nbsp;drivers/scsi/scsi_transport_<wbr>iscsi.c | 264 ++++++++++++++++++=
+++++++++++-<wbr>------
<br>&nbsp;include/scsi/scsi_transport_<wbr>iscsi.h | &nbsp; 2 +
<br>&nbsp;3 files changed, 222 insertions(+), 51 deletions(-)
<br>
<br>--=20
<br>2.1.0
<br>
<br></blockquote></div>

<p></p>

-- <br />
You received this message because you are subscribed to the Google Groups &=
quot;open-iscsi&quot; group.<br />
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to <a href=3D"mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org">open-isc=
si+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org</a>.<br />
To post to this group, send email to <a href=3D"mailto:open-iscsi@googlegro=
ups.com">open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org</a>.<br />
Visit this group at <a href=3D"http://groups.google.com/group/open-iscsi">h=
ttp://groups.google.com/group/open-iscsi</a>.<br />
For more options, visit <a href=3D"https://groups.google.com/d/optout">http=
s://groups.google.com/d/optout</a>.<br />

------=_Part_280_1078130087.1433130237684--

------=_Part_279_1560941177.1433130237684--
