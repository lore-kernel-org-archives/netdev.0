From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] fix secure tcp sequence number generation
Date: Tue, 05 Oct 2004 22:41:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41630713.2080606@colorfullife.com>
References: <415EEF0E.3080808@colorfullife.com> <20041005132724.6a913c48.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041005132724.6a913c48.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>On Sat, 02 Oct 2004 20:10:22 +0200
>Manfred Spraul <manfred@colorfullife.com> wrote:
>
>  
>
>>Description:
>>The tcp sequence number generator needs a random seed that is reset every
>>few minutes. Since the sequence numbers should be constantly increasing,
>>for each rekey 2^24 is added to the sequence number.
>>The actual use of the sequence number generator is lockless,
>>synchronization is achieved by having two copies of the control structure.
>>
>>The attached patch:
>>- fixes a race in rekey_seq_generator(): schedule_work doesn't
>>   provide synchronization.
>>- Uses schedule_delayed_work() for the rekey: simplifies synchronization
>>   and speeds up the hot path.
>>- replaces do_gettimeofday with get_seconds(): get_seconds is faster and
>>   usec resolution is not required.
>>- removes tmpdata - not needed with new locking.
>>- Adds a late_initcall for the first initialization after boot.
>>   init_call would be too early, I've checked that the late_initcall runs
>>   before net/ipv4/ipconfig.c, i.e. the BOOTP/DHCP autoconfiguration.
>>
>>Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>
>>    
>>
>
>I like this patch, but you may have sent the wrong copy.  You
>mention in the description that you changed over to use
>get_seconds(), yet the only reference to get_seconds() in the
>patch is:
>
>-	keyptr = check_and_rekey(get_seconds());
>+	keyptr = get_keyptr();
>
>Please clarify that this is just a brain fart in the description
>and not the patch.
>  
>
Right patch but wrong description, sorry:
I've recycled the description from the previous patch and that one used 
get_seconds() in rekey_seq_generator(). Now rekey_seq_generator() 
doesn't access the time at all, that's done within schedule_delayed_work().

--
    Manfred
