From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH net-next 08/10] ipv6: Do not use inetpeer when
 creating RTF_CACHE route for /128 via gateway entry
Date: Mon, 13 Apr 2015 10:51:43 -0700
Message-ID: <20150413175142.GA925334@devbig242.prn2.facebook.com>
References: <1428717576-1040383-1-git-send-email-kafai@fb.com>
 <1428717576-1040383-9-git-send-email-kafai@fb.com>
 <20150413110632.GF8928@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:7115 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751153AbbDMRv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:51:59 -0400
Content-Disposition: inline
In-Reply-To: <20150413110632.GF8928@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 01:06:32PM +0200, Steffen Klassert wrote:
> On Fri, Apr 10, 2015 at 06:59:34PM -0700, Martin KaFai Lau wrote:
> > When there is a pmtu exception on /128 via gateway route, we need to
> > create a separate metrics copy for the newly created RTF_CACHE route instead
> > of reusing the inetpeer cache.
>
> Maybe we should remove the caching of the metrics on the inetpeer
> completely. After your patchset only static hostroutes using this,
The RTF_CACHE copied from "plen <128 via gateway" route will also use
the inetpeer.

> and this is exactly the case where it is buggy. If a second route
> to the same host is added, the metrics of the first will be
> overwritten.
I agree.  The current upstream also has similar bug.
I had thought about changes as you suggested but decided to
use a separate patch instead.  I will try to consider it in v2.

Thanks,
--Martin
