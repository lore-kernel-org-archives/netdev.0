From: subashab@codeaurora.org
Subject: Re: [RFC] Handle error writing UINT_MAX to u32 fields
Date: Tue, 14 Jun 2016 14:36:41 -0600
Message-ID: <191b6c778e6e0ccf3c60e23cee724d8f@codeaurora.org>
References: <1465526452-30567-1-git-send-email-subashab@codeaurora.org>
 <575A5DF0.7020300@gmx.de> <363ac4f6f7e1a8b905af567667a1559a@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:32976 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbcFNUgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 16:36:43 -0400
In-Reply-To: <363ac4f6f7e1a8b905af567667a1559a@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-06-12 20:30, subashab@codeaurora.org wrote:
>> The suggested change would extend the usable range of positive numbers
>> by one bit only. As many systems are 64 bit this does not seem forward
>> looking.
>> 
>> I would prefer to have a routine that can handle 64 bit integers with
>> limits (let's call it proc_doint64vec_minmax) which uses fields extra1
>> and extra2 of ctl_table as min and max.
>> 
>> Then set xfrm_table[].extra1 = 0 and xfrm_table[].extra2 = UINT_MAX if
>> you need a result in the u32 range.
>> 
> 
> Thanks Heinrich. Do you think we can use proc_doulongvec_minmax for 
> this?

Actually proc_doulongvec_minmax does not work here.
I would expect similar problems due to casting if we use u64 
(proc_doint64vec_minmax) here.

static int __do_proc_doulongvec_minmax(void *data, struct ctl_table 
*table, int write,
{
	unsigned long *i, *min, *max;
	int vleft, first = 1, err = 0;

	i = (unsigned long *) data;   //This cast is causing to read beyond the 
size of data (u32)
	min = (unsigned long *) table->extra1;
	max = (unsigned long *) table->extra2;
	vleft = table->maxlen / sizeof(unsigned long); //vleft is 0 because 
maxlen is sizeof(u32) which is lesser than sizeof(unsigned long) on 
x86_64.
