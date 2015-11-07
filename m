From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [GIT] Networking
Date: Fri, 6 Nov 2015 16:49:19 -0800
Message-ID: <CALCETrWCnf_egx3wgDAgRXQwx-gCnX0xNATtv=M5QM-OdefvPw@mail.gmail.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
 <CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
 <5637C8DF.800@kernel.org> <CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
 <CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
 <CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
 <1446512176.17404.30.camel@kernel.crashing.org> <CA+55aFxas=6fg2LtcLjDB3jM9cHBj=7PnDf-8J31jc3yXNpXNQ@mail.gmail.com>
 <CALCETrUijiLwtYRwc-UHPkuhh+PoMh0scwffewuJ+7wRBR=Jfg@mail.gmail.com>
 <CA+55aFxgr=VteHvxj7EY===QbchRdLY56r7cyFxSnuF_G0rqVA@mail.gmail.com>
 <1446555200.1870849.427743457.63139285@webmail.messagingengine.com>
 <CA+55aFw-pzoSNnO_eot1c2ZJOWKrFeRhXw4oQQS9dwt4NziHfQ@mail.gmail.com>
 <CA+55aFzSD=H8pAP7B48HCCdjiB3R-Zvx3Dn=x-BjyiL+3UBeiw@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1CBCD4A0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBCD4A0@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 6, 2015 at 7:27 AM, David Laight <David.Laight@aculab.com> wrote:
>> From: Linus Torvalds
>> Sent: 03 November 2015 20:45
>> On Tue, Nov 3, 2015 at 12:05 PM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>> >      result = add_overflow(
>> >         mul_overflow(sec, SEC_CONVERSION, &overflow),
>> >         mul_overflow(nsec, NSEC_CONVERSION, &overflow),
>> >         &overflow);
>> >
>> >      return overflow ? MAX_JIFFIES : result;
>>
>> Thinking more about this example, I think the gcc interface for
>> multiplication overflow is fine.
>>
>> It would end up something like
>>
>>     if (mul_overflow(sec, SEC_CONVERSION, &sec))
>>         return MAX_JIFFY_OFFSET;
>>     if (mul_overflow(nsec, NSEC_CONVERSION, &nsec))
>>         return MAX_JIFFY_OFFSET;
>>     sum = sec + nsec;
>>     if (sum < sec || sum > MAX_JIFFY_OFFSET)
>>         return MAX_JIFFY_OFFSET;
>>     return sum;
>>
>> and that doesn't look horribly ugly to me.
>
> If mul_overflow() is a real function you've just forced some of the
> values out to memory, generating a 'clobber' for all memory
> (unless 'strict-aliasing' is enabled) and making a mess of other
> optimisations.
> (If it is a static inline that might not happen.)

I doubt anyone would ever make it a real function.  On new gcc, it
would be an inline backed by an intrinsic.  On old gcc it would be a
normal inline or perhaps an inline with inline asm in it.

--Andy
