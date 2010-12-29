From: Angelo Dureghello <angelo70@gmail.com>
Subject: Re: dm9000 patch
Date: Wed, 29 Dec 2010 09:48:08 +0100
Message-ID: <4D1AF5C8.5050809@gmail.com>
References: <4D1A5C2A.5050606@gmail.com> <20101229060637.GA31010@jasper.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101229060637.GA31010@jasper.tkos.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29/12/2010 07:06, Baruch Siach wrote:
> Hi Angelo,
>
> On Tue, Dec 28, 2010 at 10:52:42PM +0100, Angelo Dureghello wrote:
>    
>> sorry to contact you directly but i couldn't get any help from the
>> kernel.org mailing list, since i am not a developer my mails are
>> generally skipped.
>>      
> The best way to get the contact info for a piece of kernel code, is using the
> get_maintainer.pl script. Running 'scripts/get_maintainer.pl -f
> drivers/net/dm9000.c' gives the following output:
>
> netdev@vger.kernel.org
> linux-kernel@vger.kernel.org
>
> I added both to Cc.
>
>    
>> I am very near to have a custom board working with MCF5307 cpu and dm9000.
>> I am using kernel 2.6.36-rc3 with your last patch about
>> spinlock-recursion already included.
>>      
> You should try to update to the latest .36 kernel, which is currently
> 2.6.36.2. The problem that you experience might be unrelated to the dm9000
> driver (or to networking at all), so it might have been fixed in this version.
>
>    
>> I have "ping" and "telnet" to the embedded board fully working.
>> If i try to get a sample web page with some images from the board
>> httpd with a browser, in 80% of cases i get a trap/oops:
>>      
> Try to enable KALLSYMS in your kernel .config to make your stack trace more
> meaningful. This is under 'General setup ->  Configure standard kernel features
> (for small systems) ->  Load all symbols for debugging/ksymoops'.
>
> I hope this helps.
>
> baruch
>
>    
>> [    4.590000] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
>> [   67.630000] BUG: spinlock recursion on CPU#0, httpd/29
>> [   67.630000]  lock: 00c42c06, .magic: dead4ead, .owner: httpd/29,
>> .owner_cpu: 0
>> [   67.630000] Stack from 00d7b914:
>> [   67.630000]         00d7b940 000a8cf0 0015f693 00c42c06 dead4ead
>> 00dec1d4 0000001d 00000000
>> [   67.630000]         00c42c06 00006188 00c42800 00d7b974 000a8ec2
>> 00c42c06 0015f6f9 00002704
>> [   67.630000]         00000000 0000001f 00146fa4 00152f0c 00c42b60
>> 00006188 00c42800 0002b312
>> [   67.630000]         00d7b984 0014701e 00c42c06 00000000 00d7b9c4
>> 000df21c 00c42c06 00000000
>> [   67.630000]         00000000 0000001f 00146fa4 00152f0c 000005ea
>> 00cfc640 00006188 000096e8
>> [   67.630000]         0002b312 00146fa4 00c42b60 00002704 00d7b9ec
>> 00029d3a 0000001f 00c42800
>> [   67.630000] Call Trace:
>> [   67.630000]  [000a8cf0]  [000a8ec2]  [0014701e]  [000df21c]  [00029d3a]
>> [   67.630000]  [00029e84]  [00000bb6]  [0000336e]  [000df162]  [000effd6]
>> [   67.630000]  [00100482]  [000f312e]  [000f9ebc]  [0010dd2a]  [0010e4a0]
>> [   67.630000]  [0010dfb2]  [0010ef80]  [0011fed6]  [00121170]  [0012188e]
>> [   67.630000]  [0011ecc6]  [001249fe]  [000e4084]  [0011621c]  [00131a44]
>> [   67.630000]  [000e11ee]  [00041944]  [00041a1c]  [00041e46]  [00003218]
>> [   67.630000] BUG: spinlock lockup on CPU#0, httpd/29, 00c42c06
>> [   67.630000] Stack from 00d7b934:
>> [   67.630000]         00d7b974 000a8f66 0015f703 00000000 00dec1d4
>> 0000001d 00c42c06 00002704
>> [   67.630000]         00000000 0000001f 00146fa4 00152f0c 00c42b60
>> 00006188 00c42800 0002b312
>> [   67.630000]         00d7b984 0014701e 00c42c06 00000000 00d7b9c4
>> 000df21c 00c42c06 00000000
>> [   67.630000]         00000000 0000001f 00146fa4 00152f0c 000005ea
>> 00cfc640 00006188 000096e8
>> [   67.630000]         0002b312 00146fa4 00c42b60 00002704 00d7b9ec
>> 00029d3a 0000001f 00c42800
>> [   67.630000]         0016c1b4 00cfc640 0000001f 0016c178 00029d10
>> 00146fb8 00d7ba20 00029e84
>> [   67.630000] Call Trace:
>> [   67.630000]  [000a8f66]  [0014701e]  [000df21c]  [00029d3a]  [00029e84]
>> [   67.630000]  [00000bb6]  [0000336e]  [000df162]  [000effd6]  [00100482]
>> [   67.630000]  [000f312e]  [000f9ebc]  [0010dd2a]  [0010e4a0]  [0010dfb2]
>> [   67.630000]  [0010ef80]  [0011fed6]  [00121170]  [0012188e]  [0011ecc6]
>> [   67.630000]  [001249fe]  [000e4084]  [0011621c]  [00131a44]  [000e11ee]
>> [   67.630000]  [00041944]  [00041a1c]  [00041e46]  [00003218]
>>
>> As i said, i was hoping in your patch but i sadly discovered it is
>> already included in this kernel version.
>> Hope you can give me some help or can forward me to an appropriate
>> mailing list.
>>      
>    
Hi Baruch and all,
many thanks for the help,

i am going to try 2.6.36.2 and KALLSYMS.
Anyway, my purpose now is to learn as much as possible the interrupt 
handling and the spinlock part, and as much as possible about linux 
drivers, since i am very interested to enter on this and be able to fix 
issues and contribute.

regards,
angelo
