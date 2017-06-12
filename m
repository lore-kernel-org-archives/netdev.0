From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 0/6] Constant Time Memory Comparisons Are Important
Date: Mon, 12 Jun 2017 16:46:47 +0300
Message-ID: <87lgox8gjc.fsf@kamboji.qca.qualcomm.com>
References: <20170610025912.6499-1-Jason@zx2c4.com>
	<878tkzq6wi.fsf@purkki.adurom.net>
	<CAGXu5jKp=X7-eKo+HgzS3uqncx5yy-u=tJNqV9K8GOgJ=-C7iA@mail.gmail.com>
	<CANUX_P2b0Bx+-E_OBQ0reGW0=d6819qc=r83K0kTv0xMo8mtLQ@mail.gmail.com>
	<CAO1O6see6yDr-hDVNPi9Kv9wO6p-98w7YhsnnwnVOVCSEGVksw@mail.gmail.com>
	<5595d4bc-a43e-7a89-eb86-fa77556cd7af@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Emil Lenngren <emil.lenngren@gmail.com>,  Emmanuel Grumbach <egrumbach@gmail.com>,  Kees Cook <keescook@chromium.org>,  "Jason A. Donenfeld" <Jason@zx2c4.com>,  LKML <linux-kernel@vger.kernel.org>,  "kernel-hardening\@lists.openwall.com" <kernel-hardening@lists.openwall.com>,  Anna Schumaker <anna.schumaker@netapp.com>,  David Howells <dhowells@redhat.com>,  David Safford <safford@us.ibm.com>,  "David S. Miller" <davem@davemloft.net>,  Gilad Ben-Yossef <gilad@benyossef.com>,  Greg Kroah-Hartman <gregkh@linuxfoundation.org>,  Gustavo Padovan <gustavo@padovan.org>,  "J. Bruce Fields" <bfields@fieldses.org>,  Jeff Layton <jlayton@poochiereds.net>,  Johan Hedberg <johan.hedberg@gmail.com>,  Johannes Berg <johannes@sipsolutions.net>,  Marcel Holtmann <marcel@holtmann.org>,  Mimi Zohar <zoha
 r@linux.vnet.ibm.com>,  Trond Myklebust <trond.myklebust@primarydata.com>,  keyrings@vger.kernel.o
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <kernel-hardening-return-8526-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <5595d4bc-a43e-7a89-eb86-fa77556cd7af@broadcom.com> (Arend van
	Spriel's message of "Mon, 12 Jun 2017 09:33:24 +0200")
List-Id: netdev.vger.kernel.org

Arend van Spriel <arend.vanspriel@broadcom.com> writes:

> On 6/11/2017 11:30 PM, Emil Lenngren wrote:
>> 2017-06-11 22:48 GMT+02:00 Emmanuel Grumbach <egrumbach@gmail.com>:
>>> On Sun, Jun 11, 2017 at 4:36 PM, Kees Cook <keescook@chromium.org> wrote:
>>>>
>>>> On Sun, Jun 11, 2017 at 1:13 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
>>>>> "Jason A. Donenfeld" <Jason@zx2c4.com> writes:
>>>>>
>>>>>> Whenever you're comparing two MACs, it's important to do this using
>>>>>> crypto_memneq instead of memcmp. With memcmp, you leak timing information,
>>>>>> which could then be used to iteratively forge a MAC.
>>>>>
>>>>> Do you have any pointers where I could learn more about this?
>>>>
>>>> While not using C specifically, this talks about the problem generally:
>>>> https://www.chosenplaintext.ca/articles/beginners-guide-constant-time-cryptography.html
>>>>
>>>
>>> Sorry for the stupid question, but the MAC address is in plaintext in
>>> the air anyway or easily accessible via user space tools. I fail to
>>> see what it is so secret about a MAC address in that code where that
>>> same MAC address is accessible via myriads of ways.
>>
>> I think you're mixing up Media Access Control (MAC) addresses with
>> Message Authentication Code (MAC). The second one is a cryptographic
>> signature of a message.
>
> While this may be obvious to those who are in the know this mixup is
> easily made outside the crypto domain and especially in the (wireless)
> networking domain (my mind wandered towards the same error path).

I did realise that this was about Message Authentication Code (yay!) but
I got lost because I thought this is somehow related to timestamps :)
Thanks to Kees I now understand this is about revealing execution time
to the attacker, not timestamps or anything like that.

> As this series is touching stuff outside crypto it is good to be
> explicit and not use such abbreviations that can be misinterpreted.
> The article Kees referred to is also useful to get into the proper
> context here and at least worth mentioning this or other useful
> references in the cover letter.

And the kernel documentation we have is not really helping much:

/**
 * crypto_memneq - Compare two areas of memory without leaking
 *		   timing information.
 *
 * @a: One area of memory
 * @b: Another area of memory
 * @size: The size of the area.
 *
 * Returns 0 when data is equal, 1 otherwise.
 */

For most people "leaking timing information" does not tell much. Adding
a sentence or two _why_ this function should be used would be very
helpful.

-- 
Kalle Valo
