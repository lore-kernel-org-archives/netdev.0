From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] fix secure tcp sequence number generation
Date: Mon, 04 Oct 2004 06:06:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4160CC3A.4050606@colorfullife.com>
References: <415EEF0E.3080808@colorfullife.com> <20041003150052.4dba0c60.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20041003150052.4dba0c60.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>On Sat, 02 Oct 2004 20:10:22 +0200
>Manfred Spraul <manfred@colorfullife.com> wrote:
>
>  
>
>>Ted's recent random.c update broke the periodic rekeying:
>>schedule_work() doesn't provide synchronization. Additionally the first
>>syn values after boot are generated with secret 0 - not good.
>>    
>>
>
>Are you referring to his changes done back in August or some
>other change?  August is the last time I see that Ted made
>a change to drivers/char/random.c
>  
>
The change to revision 1.49 of random.c, with the comment 
"dev/random: Fix latency in rekeying sequence number"
http://linux.bkbits.net:8080/linux-2.5/diffs/drivers/char/random.c@1.49

There are two problems with that patch:
- The first call of check_and_rekey must be synchroneous, otherwise the 
secret stays 0 for the first ISN values after boot.
- schedule_work() doesn't provide synchronization, thus 
rekey_seq_generator could end up running twice.

I tried to fix it and then I noticed that it's possible to simplify the 
code a lot.
--
    Manfred
