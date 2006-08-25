From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 0/4] VM deadlock prevention -v5
Date: Fri, 25 Aug 2006 12:04:10 -0400
Message-ID: <44EF1F7A.3080001@redhat.com>
References: <20060825153946.24271.42758.sendpatchset@twins> <Pine.LNX.4.64.0608250849480.9083@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Indan Zupancic <indan@nul.nu>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Daniel Phillips <phillips@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:711 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030200AbWHYQEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 12:04:34 -0400
To: Christoph Lameter <clameter@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608250849480.9083@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter wrote:
> On Fri, 25 Aug 2006, Peter Zijlstra wrote:
> 
>> The basic premises is that network sockets serving the VM need undisturbed
>> functionality in the face of severe memory shortage.
>>
>> This patch-set provides the framework to provide this.
> 
> Hmmm.. Is it not possible to avoid the memory pools by 
> guaranteeing that a certain number of page is easily reclaimable?

No.

You need to guarantee that the memory is not gobbled up by
another subsystem, but remains available for use by *this*
subsystem.  Otherwise you could still deadlock.

-- 
What is important?  What you want to be true, or what is true?
