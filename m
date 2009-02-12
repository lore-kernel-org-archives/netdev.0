From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: Mainline kernel OLTP performance update
Date: Thu, 12 Feb 2009 18:07:51 +0200
Message-ID: <84144f020902120807v25f52301s2713d143b38f3d8c@mail.gmail.com>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <1232697998.6094.17.camel@penberg-laptop>
	 <1232699401.11429.163.camel@ymzhang>
	 <1232703989.6094.29.camel@penberg-laptop>
	 <alpine.DEB.1.10.0901231020030.21692@qirst.com>
	 <1232765728.11429.193.camel@ymzhang>
	 <84144f020901232336v71687223y2fb21ee081c7517f@mail.gmail.com>
	 <1234416153.2604.387.camel@ymzhang>
	 <1234417660.2604.391.camel@ymzhang>
	 <alpine.DEB.1.10.0902121022450.3559@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com, Ingo Molnar <mingo@elte.hu>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:8368 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbZBLQHy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 11:07:54 -0500
In-Reply-To: <alpine.DEB.1.10.0902121022450.3559@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christoph,

On Thu, 12 Feb 2009, Zhang, Yanmin wrote:
>> =EF=BB=BFThe default order of =EF=BB=BFkmalloc-8192 on 2*4 stoakley =
is an issue of calculate_order.
>>
>>
>> slab_size =C2=A0 =C2=A0 =C2=A0 order =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 name
>> -------------------------------------------------
>> 4096 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sgpool-128
>> 8192 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kmalloc-8192
>> 16384 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 3 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 kmalloc-16384
>>
>> =EF=BB=BFkmalloc-8192's default order is smaller than =EF=BB=BFsgpoo=
l-128's.

On Thu, Feb 12, 2009 at 5:25 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> You reverted the page allocator passthrough patch before this right?
> Otherwise kmalloc-8192 should not exist and allocation calls for 8192
> bytes would be converted inline to request of an order 1 page from th=
e
> page allocator.

Yup, I assume that's the case here.
