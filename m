From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] sock: don't enable netstamp for af_unix sockets
Date: Tue, 27 Oct 2015 12:09:21 +0100
Message-ID: <1445944161.1336457.421364569.5449BCCB@webmail.messagingengine.com>
References: <1445863897-22646-1-git-send-email-hannes@stressinduktion.org>
 <20151026131928.GA1820@netboy>
 <1445866379.133031.420389177.3AE9E175@webmail.messagingengine.com>
 <20151027101157.GA1850@netboy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56986 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752996AbbJ0LJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 07:09:22 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id CF75B20844
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 07:09:21 -0400 (EDT)
In-Reply-To: <20151027101157.GA1850@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

On Tue, Oct 27, 2015, at 11:11, Richard Cochran wrote:
> On Mon, Oct 26, 2015 at 02:32:59PM +0100, Hannes Frederic Sowa wrote:
> > On Mon, Oct 26, 2015, at 14:19, Richard Cochran wrote:
> > > On Mon, Oct 26, 2015 at 01:51:37PM +0100, Hannes Frederic Sowa wrote:
> > > > netstamp_needed is toggled for all socket families if they request
> > > > timestamping. But some protocols don't need the lower-layer timestamping
> > > > code at all. This patch starts disabling it for af-unix.
> > > 
> > > What problem is this patch trying to solve?
> > 
> > netstamp_needed is a static-key which enables timestamping code in the
> > networking stack receive functions for every packet, while it is not
> > needed for AF_UNIX/LOCAL. So it is merely a small performance
> > enhancement.
> 
> Are there any numbers that show the effect of this enhancement?

I haven't personally done any performance numbers.

Jesper (in Cc) noticed that it showed up in perf performance reports
even though he used a very minimal setup. Turned out that
systemd-journald enables timestamping on AF_UNIX sockets which thus
enabled netstamps globally. I think Jesper can chime in here.

Bye,
Hannes
