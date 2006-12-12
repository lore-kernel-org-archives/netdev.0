From: "Leigh Brown" <leigh@solinno.co.uk>
Subject: Re: kernel panic with the newly merged md5 signature support
Date: Tue, 12 Dec 2006 23:03:34 -0000 (GMT)
Message-ID: <45239.81.105.127.245.1165964614.squirrel@www.solinno.co.uk>
References: <36718.81.105.127.245.1165873138.squirrel@www.solinno.co.uk>
    <60194.81.105.127.245.1165962133.squirrel@www.solinno.co.uk>
    <20061212.142523.85408861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mwuml021.modern-world.net ([193.110.88.84]:2357 "EHLO
	mwuml021.modern-world.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964777AbWLLXDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 18:03:35 -0500
In-Reply-To: <20061212.142523.85408861.davem@davemloft.net>
To: "David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, December 12, 2006 10:25 pm, David Miller said:
> From: "Leigh Brown" <leigh@solinno.co.uk>
> Date: Tue, 12 Dec 2006 22:22:13 -0000 (GMT)
>
>> I'm not sure what the correct way forward is.  Could these functions
>> not be just:
>>
>> struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
>> {
>>         struct tcp_md5sig_pool **p = tcp_md5_sig_pool;
>> 	BUG_ON(!p);
>> 	return *per_cpu_ptr(p, cpu);
>> }
>>
>> void __tcp_put_md5sig_pool(void) {
>>         /* nuffin */
>> }
>>
>> In other words, can we assume that the pool is allocated when we call
>> tcp_get_md5sig_pool?
>
> I think the issue is that we need to get a balanced get_cpu()/put_cpu()
> in there somehow.

Well, the inline functions seem okay in that regard, but I'll bow to
your superior judgement.

static inline
struct tcp_md5sig_pool          *tcp_get_md5sig_pool(void)
{
        int cpu = get_cpu();
        struct tcp_md5sig_pool *ret = __tcp_get_md5sig_pool(cpu);
        if (!ret)
                put_cpu();
        return ret;
}

static inline void              tcp_put_md5sig_pool(void)
{
        __tcp_put_md5sig_pool();
        put_cpu();
}

