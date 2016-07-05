From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH 2/3] netfilter: Create revision 2 of xt_hashlimit to
 support higher pps rates
Date: Tue, 5 Jul 2016 18:39:49 -0400
Message-ID: <577C3735.2060207@akamai.com>
References: <20160602001138.GB1644@akamai.com> <20160623111630.GA2717@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160623111630.GA2717@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/23/2016 07:16 AM, Pablo Neira Ayuso wrote:
> On Wed, Jun 01, 2016 at 08:11:38PM -0400, Vishwanath Pai wrote:
>> +static void
>> +cfg_copy(struct hashlimit_cfg2 *to, void *from, int revision)
>> +{
>> +	if (revision == 1) {
>> +		struct hashlimit_cfg1 *cfg = (struct hashlimit_cfg1 *)from;
>> +
>> +		to->mode = cfg->mode;
>> +		to->avg = cfg->avg;
>> +		to->burst = cfg->burst;
>> +		to->size = cfg->size;
>> +		to->max = cfg->max;
>> +		to->gc_interval = cfg->gc_interval;
>> +		to->expire = cfg->expire;
>> +		to->srcmask = cfg->srcmask;
>> +		to->dstmask = cfg->dstmask;
>> +	} else if (revision == 2) {
>> +		memcpy(to, from, sizeof(struct hashlimit_cfg2));
>> +	} else {
>> +		BUG();
> 
> BUG here is probably too much, this halts the system. I can see we
> only use this somewhere else in this code. Instead, I'd suggest you
> propagate an error back to userspace if this ever happen.
> 
> I would like to see if this spots any problem with our test
> infrastructure under iptables/.
> 
> Thanks.
> 

copy_cfg is only used internally by the kernel module and the value for
revision is passed to the function by the module itself and not from
userspace. I will remove BUG() and propagate the error back to the
caller, will send a v2.
