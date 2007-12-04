From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [0/4] DST: Distributed storage.
Date: Tue, 4 Dec 2007 10:25:29 -0500
Message-ID: <170fa0d20712040725o506a47cayb137993041ec3a63@mail.gmail.com>
References: <aqqqqasdzxczc036@2ka.mipt.ru> <11967790263179@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:57414 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990AbXLDPZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 10:25:31 -0500
Received: by nz-out-0506.google.com with SMTP id s18so2348162nze
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2007 07:25:29 -0800 (PST)
In-Reply-To: <11967790263179@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 4, 2007 9:37 AM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
>
> Distributed storage.
>
> I'm pleased to announce the 10'th release of the distributed
> storage subsystem (DST). This is a maintenance release and includes
> bug fixes and simple feature extensions only.
>
> DST allows to form a storage on top of local and remote nodes
> and combine them into linear or mirroring setup, which in
> turn can be exported to remote nodes.
>
> Short changelog:
>  * fixed bug with XFS metadata update (it can provide slab pages to the
>         DST, so it is not allowed to transfer them using ->sendpage())
>  * fixed async error completion path
>  * extended netlink communication channel to report errors back to userspace
>  * DST name is now "The 10'th dynasty of smuggled slothes"
>  * number of fixes for userspace DST target
>
> Great thanks to Matthew Hodgson <matthew@mxtelecom.com> for debugging and
> fixes for userspace DST target and preliminary netlink extension patches.
>
> Overall list of features of the DST can be found on project's homepage:
>
> http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst
>
> Thank you.
>
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

Evgeniy,

Thanks for your continued work on DST.  I'd like to know if you've
thought further about how synchronous mirroring would be best
implemented with DST.

You shared you views some time ago via comments on your blog:
http://tservice.net.ru/~s0mbre/blog/devel/dst/2007_11_05.html

At that time you were saying you'd add a sync bit to the request
structure that is sent to remote nodes.  I'd imagine this would also
require ordering of the block io, no?  Is order guaranteed when the
requests are submitted over the DST protocol?  Otherwise how can you
ensure a valid remote mirror (in the case of network disconnects,
etc)?

Guaranteeing consistent data on all members of a mirror is important.
The main question is: what mechanisms _should_ be used in DST to
provide this consistency?  And do you have a timeframe for when DST
might support such mechanisms for consistent data?

For the purpose of this discussion please assume that the disk cache
is either write-through or battery-backed.

regards,
Mike
