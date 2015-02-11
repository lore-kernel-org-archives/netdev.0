From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Wed, 11 Feb 2015 09:42:09 +0200
Message-ID: <20150211094209.11f2ea4e@pixies.home.jungo.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
	<54D3F8F9.2060500@cumulusnetworks.com>
	<20150206081046.415c3d50@halley>
	<54D8D84A.2080203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
	ebiederm@xmission.com, Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	hannes@stressinduktion.org, Eyal Birger <eyal.birger@gmail.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:60845 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbbBKHmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 02:42:17 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so1632306wgh.6
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 23:42:16 -0800 (PST)
In-Reply-To: <54D8D84A.2080203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 09 Feb 2015 07:54:50 -0800 roopa <roopa@cumulusnetworks.com> wrote:
> On 2/5/15, 10:10 PM, Shmulik Ladkani wrote:
> > On Thu, 05 Feb 2015 15:12:57 -0800 roopa <roopa@cumulusnetworks.com> wrote:
> >> We have been playing with ip rules to implement vrfs. And the blocker
> >> today is that we cannot bind a socket to a vrf (routing tables in this
> >> case).
> >
> > One option would be using SO_MARK sockopt on that socket, and have an ip
> > rule which matches this mark to point to your table.
> > I don't know your exact use-cases, but you can play around with that
> > idea.
> 
>   yes, SO_MARK and 'ip rule fwmark'  is an option to bind tx from a socket
> to a table. But, There are more things that will be needed on the rx side.
> and at this point we are not considering netfilter marking of the 
> ingress packets so haven't been following this option

In the past we've implemented small-scale L3 segmentation using multiple
tables, without using netfilter marking.

We've used 'iif' rules for rx (as application knows its interface-to-vrf
mapping, it may provision 'iif' rules to point to the appropriate table).
For locally originated traffic, SO_MARK and 'mark' rules were used.

An 'ingress-netdevice to mark' mapping would make such solution less
awkward, but one might claim such mapping is not generic as it leaks
application specific knowledge and logic into the network stack.

Also, the downside of using multiple-tables based solution might
probably be lack of scalability, as the amount of ip rules in such a
scheme grows linearily with number of L3 segments.

Regards,
Shmulik
