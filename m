From: Gary R Hook <ghook@amd.com>
Subject: Re: padata - is serial actually serial?
Date: Wed, 15 Jun 2016 08:53:42 -0500
Message-ID: <57615DE6.6000407@amd.com>
References: <CAHmME9qnufO90qF7v9bVb7L+6KQA=kaZ=BML2sRwzbQHtFLJGA@mail.gmail.com>
 <20160615115203.GB7698@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-crypto@vger.kernel.org>, Netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20160615115203.GB7698@gauss.secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/15/2016 06:52 AM, Steffen Klassert wrote:
> Hi Jason.
>
> On Tue, Jun 14, 2016 at 11:00:54PM +0200, Jason A. Donenfeld wrote:
>> Hi Steffen & Folks,
>>
>> I submit a job to padata_do_parallel(). When the parallel() function
>> triggers, I do some things, and then call padata_do_serial(). Finally
>> the serial() function triggers, where I complete the job (check a
>> nonce, etc).
>>
>> The padata API is very appealing because not only does it allow for
>> parallel computation, but it claims that the serial() functions will
>> execute in the order that jobs were originally submitted to
>> padata_do_parallel().
>>
>> Unfortunately, in practice, I'm pretty sure I'm seeing deviations from
>> this. When I submit tons and tons of tasks at rapid speed to
>> padata_do_parallel(), it seems like the serial() function isn't being
>> called in the exactly the same order that tasks were submitted to
>> padata_do_parallel().
>>
>> Is this known (expected) behavior? Or have I stumbled upon a potential
>> bug that's worthwhile for me to investigate more?
>
> It should return in the same order as the job were submitted,
> given that the submitting cpu and the callback cpu are fixed
> for all the jobs you want to preserve the order.  If you submit
> jobs from more than one cpu, we can not know in which order
> they are enqueued. The cpu that gets the lock as the first
> has its job in front.

Isn't there an element of indeterminacy at the application thread level
(i.e. user space) too? We don't know how the jobs are being submitted, but
unless that is being handled by a single thread in a single process, I
think all bets are off with respect to ordering.

Then again, perhaps I'm not grokking the details here.

> Same if you use more than one callback cpu
> we can't know in which order they are dequeued, because the
> serial workers are scheduled independent on each cpu.
