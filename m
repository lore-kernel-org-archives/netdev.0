From: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 2.6] SoftMAC : fix ESSID problem
Date: Mon, 09 Jul 2007 18:40:44 -0500
Message-ID: <4692C77C.30005@lwfinger.net>
References: <20070709221922.GB1381@bougret.hpl.hp.com> <200707100046.23832.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org, "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200707100046.23832.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Tuesday 10 July 2007 00:19:22 Jean Tourrilhes wrote:
>> 	Hi,
>>
>> 	Victor Porton reported that the SoftMAC layer had random
>> problem when setting the ESSID :
>> 		http://bugzilla.kernel.org/show_bug.cgi?id=8686
>> 	After investigation, it turned out to be worse, the SoftMAC
>> layer is left in an inconsistent state. The fix is pretty trivial.
>>         John : would you mind pushing that to 2.6.23 ?
>>         Thanks...
>>
>>         Jean
>>
>> Signed-off-by: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
>>
>> -----------------------------------------------------------
>>
>> --- linux/net/ieee80211/softmac/ieee80211softmac_assoc.j1.c	2007-07-09 13:56:13.000000000 -0700
>> +++ linux/net/ieee80211/softmac/ieee80211softmac_assoc.c	2007-07-09 13:56:41.000000000 -0700
>> @@ -271,8 +271,11 @@ ieee80211softmac_assoc_work(struct work_
>>  			 */
>>  			dprintk(KERN_INFO PFX "Associate: Scanning for networks first.\n");
>>  			ieee80211softmac_notify(mac->dev, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, ieee80211softmac_assoc_notify_scan, NULL);
>> -			if (ieee80211softmac_start_scan(mac))
>> +			if (ieee80211softmac_start_scan(mac)) {
>>  				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
>> +				mac->associnfo.associating = 0;
>> +				mac->associnfo.associated = 0;
>> +			}
>>  			goto out;
>>  		} else {
>>  			mac->associnfo.associating = 0;
>>
> 
> Acked-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Acked-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

This patch should also be sent to stable-DgEjT+Ai2yi4UlQgPVntAg@public.gmane.org

Larry
