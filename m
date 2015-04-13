From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH net-next 08/10] ipv6: Do not use inetpeer when
 creating RTF_CACHE route for /128 via gateway entry
Date: Mon, 13 Apr 2015 13:06:32 +0200
Message-ID: <20150413110632.GF8928@secunet.com>
References: <1428717576-1040383-1-git-send-email-kafai@fb.com>
 <1428717576-1040383-9-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57061 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753456AbbDMLGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 07:06:35 -0400
Content-Disposition: inline
In-Reply-To: <1428717576-1040383-9-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 06:59:34PM -0700, Martin KaFai Lau wrote:
> When there is a pmtu exception on /128 via gateway route, we need to
> create a separate metrics copy for the newly created RTF_CACHE route instead
> of reusing the inetpeer cache.

Maybe we should remove the caching of the metrics on the inetpeer
completely. After your patchset only static hostroutes using this,
and this is exactly the case where it is buggy. If a second route
to the same host is added, the metrics of the first will be
overwritten.
