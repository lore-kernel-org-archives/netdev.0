From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH v3 2/2] netfilter: Create revision 2 of xt_hashlimit to
 support higher pps rates
Date: Thu, 22 Sep 2016 14:39:45 -0400
Message-ID: <57E42571.1060502@akamai.com>
References: <20160922164344.GB20423@akamai.com>
 <alpine.LSU.2.20.1609221850530.27197@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, johunt@akamai.com,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Jan Engelhardt <jengelh@inai.de>, pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.20.1609221850530.27197@nerf40.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for pointing this out, I will reorder the fields to:

struct hashlimit_cfg2 {
	__u64 avg;    /* Average secs between packets * scale */
	__u64 burst;
	__u32 mode; /* bitmask of XT_HASHLIMIT_HASH_* */

This should fix the hole and avoid padding.

-Vishwanath

On 09/22/2016 12:53 PM, Jan Engelhardt wrote:
> On Thursday 2016-09-22 18:43, Vishwanath Pai wrote:
>> >+struct hashlimit_cfg2 {
>> >+	__u32 mode;	  /* bitmask of XT_HASHLIMIT_HASH_* */
>> >+	__u64 avg;    /* Average secs between packets * scale */
>> >+	__u64 burst;  /* Period multiplier for upper limit. */
> This would have different sizes between i386 and x86_64,
> necessiting additional compat functions. It should be padded
> or reordered instead.
> 

