From: David Miller <davem@redhat.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Tue, 22 Mar 2016 16:17:01 -0400 (EDT)
Message-ID: <20160322.161701.1538082255367614747.davem@redhat.com>
References: <CAKgT0Ud9uPG+9AdT47Q1VygLBnjygyY29sRf=y4Pqe=f2e+bkw@mail.gmail.com>
	<56F19FAA.3090005@solarflare.com>
	<CAEh+42jq1byHx0yuZgUCLqfk3G3eGfhoA1oq4Wwn5SmefCbNnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, alexander.duyck@gmail.com,
	aduyck@mirantis.com, netdev@vger.kernel.org, tom@herbertland.com
To: jesse@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38858 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541AbcCVURC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 16:17:02 -0400
In-Reply-To: <CAEh+42jq1byHx0yuZgUCLqfk3G3eGfhoA1oq4Wwn5SmefCbNnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@kernel.org>
Date: Tue, 22 Mar 2016 13:11:21 -0700

> Features that have been designed this way in the past are usually
> pretty fragile. Not only would you have to track changes in the
> routing table but you could have bridges, tc, vlan devices, etc. all
> of which might change the path of the packet and would have to somehow
> propagate this information. It's much more robust to resolve the
> device capabilities just before you hand the packet to that device.
> Plus, anything along the path of the packet (iptables, for example)
> that looks at the headers might potentially need to be aware of this
> optimization.

Indeed, this is a major fundamental issue in our stack right now.  I
keep being reminded of that ugly change we had to make to accomodate
scatter-gather limitations for Infiniband devices, exactly because
properties don't propagate properly through all of the layers right
now.

But we have to solve this somehow, the packetizer has to know certain
basic properties of the ultimate device in order to function properly.

This requirement is unavoidable.
