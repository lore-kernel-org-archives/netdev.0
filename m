From: emann@mrv.com (Eran Mann)
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Wed, 06 Apr 2005 16:36:20 +0300
Message-ID: <4253E5D4.60504@mrv.com>
References: <20050405213023.0256.LARK@linux.net.cn>	<1112717495.1076.22.camel@jzny.localdomain>	<20050406143842.026B.LARK@linux.net.cn> <20050406123036.GO26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wang Jian <lark@linux.net.cn>, hadi@cyberus.ca,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050406123036.GO26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> We need to provide some kind of option to the user so he can specify
> the needs.  The & 0xFF will suit most just fine but has one essential
> drawback which is that no distribution is done at all if the lower 8
> bits are set to 0. For static marks this is no issue at all and even
> for enumerated marks growing it takes quite some time to grow into
> an area where it starts hurting. The problem obviously is if someone
> splits the mark field into 2 parts and uses the upper 16 bits for
> some special purpose just like you did. In such as case it would make
> sense to either take all bits into account or let the user specify
> a bitmask + shift.
> 
> So here is the same idea I posted before but revised:
> 
> Let the user specify one of the hash tables via a new TLV:
>  - default: & 0xFF
>  - ((mark & mask) >> shift) & 0xFF
>  - jenkins for 16, 32, and 64 bits
>  - FNV for 16, 32, and 64 bits
> 
> Why variations for type sizes? The chance of collisions reduces
> a lot if the user exactly knows he'll never use more than 16bits
> but 255 marks are not enough.
> 
> I'm cooking up a patch for this today together with a fix to
> allow 64bit values for the mark.
> 

Maybe you could add to the list of options a XOR of bytes hash, 
something like:
static inline u8 bytes_xor_u32( u32 key )
{
	u8 *dummy_array = (u8 *)&key;
	u8 hash = dummy_array[0] ^ dummy_array[1] ^
		  dummy_array[2] ^ dummy_array[3];

	return hash;
}

-- 
Eran Mann
MRV International
www.mrv.com
