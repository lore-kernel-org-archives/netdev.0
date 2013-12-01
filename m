From: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Sun, 01 Dec 2013 19:50:27 +0800
Message-ID: <529B2283.7040808@gmail.com>
References: <528AEFB7.4060301@gmail.com>   <20131125011938.GB18921@codeaurora.org> <5292B845.3010404@gmail.com>   <5292B8A0.7020409@gmail.com> <5294255E.7040105@gmail.com>   <52957ADA.2080704@gmail.com>   (sfid-20131127_055211_558798_A7DF5684) <1385739487.8656.1.camel@jlt4.sipsolutions.net>   <5299D306.7070701@gmail.com>   (sfid-20131130_125901_519610_EDA4068E) <1385816013.4327.1.camel@jlt4.sipsolutions.net>   <5299ED38.4090509@gmail.com> <5299EFDD.6060405@gmail.com>   (sfid-20131130_150205_984535_068F14A9) <1385842134.6108.4.camel@jlt4.sipsolutions.net>  <1385843940.2664.4.camel@joe-AO722> <529A7955.9010507@gmail.com>  (sfid-20131201_004838_825869_AF1FBAAC) <1385890647.4171.3.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	rkuo <rkuo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1385890647.4171.3.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/01/2013 05:37 PM, Johannes Berg wrote:
> On Sun, 2013-12-01 at 07:48 +0800, Chen Gang wrote:
> 
>> If ieee80211_subif_start_xmit() is not performance sensitive (I guess
>> so), we can use some short static functions instead of some code blocks
>> within ieee80211_subif_start_xmit().
>>
>>  - ieee80211_subif_start_xmit() is a long function (600+ lines).
>>
>>  - use short static function can share some code.
>>
>>  - if code can be shared, the work flow can be more clearer too (don't
>>    need fall-through or goto).
> 
> Frankly, I'm getting tired of discussing this. Please don't try to
> rewrite this code until you've understood it. You suggesting that
> "start_xmit()" isn't a performance sensitive function makes me realize
> you haven't even tried.
> 

OK, thank you for "you are getting tired ...". Please help try when you
have time.  :-)

No I didn't try -- so use 'if' and 'guess' for discussing.

Hmm... if it is performance sensitive:

 - use static function instead of some code block and try to share them.
   it adds additional instructions, but can shrink binary code size.
   if the performance is acceptable, it is the best way to me.

 - else (1st way not acceptable), use macro instead of static function.
   it expends binary code size, but can save some instructions.
   if the performance is acceptable, it is the acceptable way to me.

 - If neither of static function nor macro are acceptable,
   I still prefer to use 'goto' instead of 'fall-through'.
   that can let all compilers feel well, and can not feel any strange.

     normally, when prev case uses fall-through,
     it need be sure of next case need not notice about it (prev case).
     or it will make a little strange for readers when read next case.


Welcome any suggestions or completions.

Thanks.
-- 
Chen Gang
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
