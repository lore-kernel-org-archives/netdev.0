From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next] net: Add l3mdev cgroup
Date: Mon, 4 Jan 2016 12:59:15 -0700
Message-ID: <568ACF13.3030007@cumulusnetworks.com>
References: <1451925136-13327-1-git-send-email-dsa@cumulusnetworks.com>
 <20160104175836.GA11668@mtj.duckdns.org>
 <568ABFC3.3010803@cumulusnetworks.com>
 <20160104185936.GA3807@mtj.duckdns.org>
 <568AC534.1070308@cumulusnetworks.com>
 <20160104192301.GC3807@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	shm@cumulusnetworks.com, roopa@cumulusnetworks.com
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:33975 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbcADT7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 14:59:32 -0500
Received: by mail-ob0-f179.google.com with SMTP id wp13so122311242obc.1
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 11:59:31 -0800 (PST)
In-Reply-To: <20160104192301.GC3807@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/4/16 12:23 PM, Tejun Heo wrote:
> I don't have an answer for that but cgroup isn't a place to put such
> stray configurations either.  Please figure out where the
> configuration belongs first.  What you're proposing really isn't a
> resource controller.  There's no resource being distributed
> hierarchically.  It's just dumping configuration which hasn't found
> its proper place into cgroup.

cgroups have very nice properties that I want to leverage such as 
parent-child inheritance and easy tracking which subsystem instance a 
task belongs. This provides a great kernel foundation for building easy 
to use management tools.

The documentation for cgroups does not restrict a controller to physical 
resources but rather "it may be anything that wants to act on a group of 
processes." That is exactly what I am doing here - I have a network 
config that is applied to a group of processes similar to net_cls and 
net_prio (but as I stated before those are orthogonal, independent 
settings from the L3 domain).
