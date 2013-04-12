From: William Dauchy <wdauchy@gmail.com>
Subject: Re: [PATCH V4 7/7] xen-netback: don't disconnect frontend when seeing
 oversize packet
Date: Fri, 12 Apr 2013 19:17:38 +0200
Message-ID: <CAJ75kXb1Pc83sAjqDuzeGiikTcqdqrgPTxTT7kS-agUqoZp7LA@mail.gmail.com>
References: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com> <1365776646-10796-8-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, xen-devel <xen-devel@lists.xen.org>,
	annie.li@oracle.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	Ian Campbell <ian.campbell@citrix.com>, david.vrabel@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:62879 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab3DLRSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 13:18:00 -0400
Received: by mail-ve0-f173.google.com with SMTP id cy12so2627883veb.18
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 10:17:59 -0700 (PDT)
In-Reply-To: <1365776646-10796-8-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 12, 2013 at 4:24 PM, Wei Liu <wei.liu2@citrix.com> wrote:
> Some frontend drivers are sending packets > 64 KiB in length. This length
> overflows the length field in the first slot making the following slots have
> an invalid length.
>
> Turn this error back into a non-fatal error by dropping the packet. To avoid
> having the following slots having fatal errors, consume all slots in the
> packet.
>
> This does not reopen the security hole in XSA-39 as if the packet as an
> invalid number of slots it will still hit fatal error case.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Maybe this should be tagged for stable? Maybe part of patch 6/7 as
well. I had to remove the part which was disabling the device because
of issues encountered in stable tree.

--
William
