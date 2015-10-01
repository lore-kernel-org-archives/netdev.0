From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [RFC PATCH 0/3] net: dsa: Complete and fix the dsa unbinding
Date: Thu, 1 Oct 2015 17:19:39 +0200
Message-ID: <560D4F0B.9080703@baylibre.com>
References: <560B9B70.6030202@baylibre.com> <560C1F5A.5070506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
	linux@roeck-us.net
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36849 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755401AbbJAPTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 11:19:42 -0400
Received: by wicgb1 with SMTP id gb1so34765353wic.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 08:19:41 -0700 (PDT)
In-Reply-To: <560C1F5A.5070506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2015 07:43 PM, Florian Fainelli wrote:
> On 30/09/15 01:21, Neil Armstrong wrote:
>> In order to cleanly unbind the dsa core, either as a module removal,
>> or a platform device unbind, switch the allocation the their devm_
>> counterparts and complete the destroy functions.
>>
>> The last patch is an experimental way to exit the probe when no
>> switch is found in the discover process.
>>
>> The patches are based on the current net-next.
> 
> I looked at the patches and they bring DSA in a better direction. For
> future submissions, could you CC people who recently worked on DSA, like
> Andrew Lunn, Guenter Roeck, Vivien Didelot and myself? We can typically
> give your patches a try fairly quickly.
> 
> In case you are seriously considering making DSA a loadable module,
> there were an earlier attempt here:
> 
> http://comments.gmane.org/gmane.linux.network/345803
> 
> Thanks!
> 
>>
>> Neil Armstrong (3):
>>   net: dsa: Use devm_ prefixed allocations
>>   net: dsa: complete dsa_switch_destroy calls
>>   net: dsa: exit probe if no switch were found
>>
>>  net/dsa/dsa.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++-------
>>  1 file changed, 60 insertions(+), 7 deletions(-)
>>
> 
> 

At least, the following patch could be added with no pain to complete my code :
[PATCH net-next 5/8] net: dsa: allow switch drivers to cleanup their resource (http://permalink.gmane.org/gmane.linux.network/345805)

Then, the following patch could be re-proposed :
[PATCH net-next 7/8] net: dsa: bcm_sf2: cleanup resources in remove callback

I should probably also take this part also :
+	dst->master_netdev->dsa_ptr = NULL;
+	/* If we used a tagging format that doesn't have an ethertype
+	 * field, make sure that all packets from this point get sent
+	 * without the tag and go through the regular receive path.
+	 */
+	wmb();
+

Neil
