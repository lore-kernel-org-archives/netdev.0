From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH 4/5] ISDN-Gigaset: Release memory in gigaset_initcs()
 after an allocation failure
Date: Tue, 27 Sep 2016 17:10:23 +0200
Message-ID: <e2f7c915-45f0-0716-4a58-2da9a79a0335@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
 <1474924434.8546.29.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Tilman Schmidt <tilman@imap.cc>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474924434.8546.29.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> @@ -772,8 +775,9 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
>>  
>>  	gig_dbg(DEBUG_INIT, "cs initialized");
>>  	return cs;
>> -
>> -error:
>> +free_bcs:
>> +	kfree(cs->bcs);
>> +report_failure:
>>  	gig_dbg(DEBUG_INIT, "failed");
>>  	gigaset_freecs(cs);
> 
> gigaset_freecs() is not a function I look at for the fun of it. But
> still, in it we find:
> 
> 	case 0: /* error in basic setup */
> 		[...]
> 		kfree(cs->inbuf);
> 		kfree(cs->bcs);
> 
> As far as I can tell we will call those two kfree()'s if we jump to
> "error". So, contrary to your analysis, I don't think we leak cs->bcs.

You are right.

Thanks that you pointed this source code place out again.

I imagined that the exception handling implementation could be more direct
somehow for a while. But this function takes extra care for data synchronisation
by a mutex.

Now I recognise also that this proposed update step "4" was inappropriate.
I'm sorry for the confusion I introduced here.

Regards,
Markus
