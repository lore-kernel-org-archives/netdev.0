From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Wed, 2 Dec 2015 10:45:37 +0100
Message-ID: <565EBDC1.1090808@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
 <564CEB0C.40006@redhat.com> <564CEF5D.3080005@profihost.ag>
 <564D9A17.6080305@redhat.com> <564D9B21.302@profihost.ag>
 <564D9CE6.2090104@profihost.ag>
 <1447933294.1974772.444210441.67F1AC5E@webmail.messagingengine.com>
 <564DB5F5.9060208@profihost.ag>
 <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com>
 <564DC4A5.70104@profihost.ag> <564DCC4C.1090009@redhat.com>
 <564E2852.8000200@profihost.ag> <56530A42.6030609@profihost.ag>
 <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Weimer <fweimer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

here are the results.

It works with 4.1.
It works with 4.2.
It does not work with 4.1.13.

git bisect tells me it stopped working after those two commits were applied:

commit d48623677191e0f035d7afd344f92cf880b01f8e
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue Sep 22 11:38:56 2015 +0800

    netlink: Replace rhash_portid with bound

commit 4e27762417669cb459971635be550eb7b5598286
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Sep 18 19:16:50 2015 +0800

    netlink: Fix autobind race condition that leads to zero port ID

Stefan
Am 23.11.2015 um 13:57 schrieb Hannes Frederic Sowa:
> On Mon, Nov 23, 2015, at 13:44, Stefan Priebe - Profihost AG wrote:
>> Am 19.11.2015 um 20:51 schrieb Stefan Priebe:
>>>
>>> Am 19.11.2015 um 14:19 schrieb Florian Weimer:
>>>> On 11/19/2015 01:46 PM, Stefan Priebe - Profihost AG wrote:
>>>>
>>>>> I can try Kernel 4.4-rc1 next week. Or something else?
>>>>
>>>> I found this bug report which indicates that 4.1.10 works:
>>>>
>>>>    <https://issues.asterisk.org/jira/browse/ASTERISK-25251>
>>>>
>>>> But in your original report, you said that 4.1.13 is broken.
>>>
>>> That's correct i'm running 4.1.13.
>>>
>>>> This backtrace:
>>>>
>>>>    <https://issues.asterisk.org/jira/secure/attachment/52702/bt.txt>
>>>>
>>>> shows a lot of waiting on quite different netlink sockets.  So if this
>>>> is due to a race in Asterisk, it must have happened several times in a
>>>> row.
>>
>> Kernel 4.4-rc2 works fine. How can we grab / get an idea which is
>> causing the isse in 4.1? It's an LTE kernel so it should be fixed!
> 
> Thanks for testing. I was not able to reproduce it at all, with as much
> parallelism and threads as possible on any kernel. Could you try to do a
> git bisect?
> 
> Thanks,
> Hannes
> 
