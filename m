From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 2/2] x86: get more exact nr_irqs
Date: Mon, 04 Jan 2010 11:30:42 -0800
Message-ID: <4B4241E2.1020008@zytor.com>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	<4B398ECD.1080506@kernel.org>	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>	<4B415E73.1050801@kernel.org> <4B41918D.3000605@kernel.org>	<m1fx6lizc3.fsf@fess.ebiederm.org>	<86802c441001041103s5abd6d3ai4e6ccbfc68323f3c@mail.gmail.com> <m1bph9he9m.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yinghai@kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:48794 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643Ab0ADTdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 14:33:41 -0500
In-Reply-To: <m1bph9he9m.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2010 11:16 AM, Eric W. Biederman wrote:
> 
> If we care about memory use efficiency let's replace irq_desc_ptrs
> with a rbtree or a radix_tree.  Something that moves the memory use
> penalty onto those machines that have a lot of irqs.
> 

rbtree doesn't make much sense for something that is addressed by index,
and doesn't need to answer questions of the form "give me the highest
member <= X".  A hash table or radix tree makes sense, depending on the
expected sparseness of the index.

	-hpa

