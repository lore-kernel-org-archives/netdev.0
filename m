From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] iproute: restrict hoplimit values to be in
 range [1;255]
Date: Mon, 23 Nov 2015 15:48:44 -0800
Message-ID: <20151123154844.5466a6e3@xeon-e3>
References: <1447160049-29214-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:16294 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751625AbbKWXsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 18:48:41 -0500
In-Reply-To: <1447160049-29214-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2015 13:54:09 +0100
Phil Sutter <phil@nwl.cc> wrote:

> Technically, the range of possible hoplimit values are defined by IPv4
> and IPv6 header formats. Both define the field to be eight bits in size,
> which leads to a value range of [0;255]. Setting a packet's hoplimit
> field to 0 though makes not much sense, as the next hop would
> immediately drop the packet. Therefore Linux uses 0 as a special value
> indicating to use the system's default hoplimit (configurable via
> sysctl). In iproute, setting the hoplimit of a route to 0 is equivalent
> to omitting the hoplimit parameter alltogether, so it is not necessary
> to allow that value to be specified.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Even though it doesn't make much sense to set hoplimit of 0;
I am concerned that some user is doing that now, and changing this
would break a working (but not optimum or sane) configuration.
Especially if actual config is auto-generated.
