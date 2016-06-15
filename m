From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH] netfilter/nflog: nflog-range does not truncate packets
Date: Wed, 15 Jun 2016 10:55:05 -0400
Message-ID: <57616C49.7090403@akamai.com>
References: <20160602002354.GG1644@akamai.com> <20160606223106.GA1621@salvia>
 <57575367.4010604@akamai.com> <20160608121625.GA4097@salvia>
 <5759AE1B.2080500@akamai.com> <575E2B49.7090809@akamai.com>
 <20160615123945.GA3594@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com,
	"Lubashev, Igor" <ilubashe@akamai.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:55225 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932370AbcFOOzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 10:55:07 -0400
In-Reply-To: <20160615123945.GA3594@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/2016 08:39 AM, Pablo Neira Ayuso wrote:
> But nlmsg_len should match len in this.
> 
> If we're just sending a part of the packet to userspace, then we
> should adjust nlmsg_len to indicate exactly the netlink message length
> that we're sending to userspace.
> 
> Is your patch triggering this nlmsg_len != len?

The value of len here is how many bytes were returned by recv. We do
send the entire nlmsg_len to userspace, but recv cannot copy the full
packet because the buffer is not big enough to hold this. They only
allocate the buffer assuming that the packet won't be bigger than their
snap len, but we send more data than their snap len and they don't
handle this condition well.
