From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 2/2] adm8211: fix the possible pci cache line sizes inside switch-case
Date: Mon, 11 May 2015 09:30:18 +0300
Message-ID: <87k2wflj7p.fsf@kamboji.qca.qualcomm.com>
References: <20150505224020.GA3805@bytefire-computer>
	<87wq0ms3mv.fsf@kamboji.qca.qualcomm.com>
	<20150506063241.GA3042@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Okash Khawaja <okash.khawaja@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150506063241.GA3042@bytefire-computer> (Okash Khawaja's
	message of "Wed, 6 May 2015 07:32:42 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Okash Khawaja <okash.khawaja@gmail.com> writes:

> On Wed, May 06, 2015 at 07:59:04AM +0300, Kalle Valo wrote:
>> Okash Khawaja <okash.khawaja@gmail.com> writes:
>> 
>> > The PCI cache line size value was being compared against decimal
>> > values prefixed with 0x.
>> > Fixed the literals to use the correct hex values.
>> >
>> > Signed-off-by: Okash Khawaja <okash.khawaja@gmail.com>
>>  [...]
>> 
>> > @@ -1101,10 +1101,10 @@ static void adm8211_hw_init(struct
>> > ieee80211_hw *dev) case 0x8: reg |= (0x1 << 14); break; - case
>> > 0x16: + case 0x10: reg |= (0x2 << 14); break; - case 0x32: + case
>> > 0x20: reg |= (0x3 << 14); break; default:
>>  Did you test this? How certain can we be that this doesn't break
>> anything?
>> 
>
> I didn't test it as that would require the hardware that I don't have
> at the moment. However, the value in `cline` is PCI cache line size,
> which is the CPU's cache line size. It is less likely for cache line
> sizes to be 22 or 50, and more likely for them to be 16 or 32. Also,
> as far as I understand (and I might be wrong here), cache line size is
> used for things like aligning DMA requests with CPU cache line, which
> improve performance but wouldn't break anything if the value doesn't
> match. In this case, we will fall through to the default case which
> leaves `reg` unchanged.
>
> If there is a way to test it with a mock set up or if you still think
> we need to test this on real board, I'll be happy to try get the
> hardware. But I will need some guidance around that. Thanks.

I don't have any ideas how to test this as I think the hardware is
pretty rare nowadays but I think this is safe to commit, thanks for
clearing this up. BTW, what you wrote about would have been perferct in
the commit log itself.

-- 
Kalle Valo
