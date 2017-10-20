From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 5/6] devlink: Adding num MSI-X vectors per VF
 NVRAM config param
Date: Fri, 20 Oct 2017 08:44:47 +0200
Message-ID: <20171020064447.GA1960@nanopsycho.orion>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-6-git-send-email-steven.lin1@broadcom.com>
 <AM0PR0502MB368347E87E48F7EB04AF1513BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
 <20171019213955.GG1978@nanopsycho.orion>
 <20171019214339.GH1978@nanopsycho.orion>
 <d9968b08-eeb7-267a-cb55-48e5feeee922@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval Mintz <yuvalm@mellanox.com>,
        Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:55418 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751193AbdJTGot (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 02:44:49 -0400
Received: by mail-wm0-f67.google.com with SMTP id u138so20511683wmu.4
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 23:44:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <d9968b08-eeb7-267a-cb55-48e5feeee922@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 20, 2017 at 03:01:35AM CEST, f.fainelli@gmail.com wrote:
>On 10/19/2017 02:43 PM, Jiri Pirko wrote:
>> Thu, Oct 19, 2017 at 11:39:55PM CEST, jiri@resnulli.us wrote:
>>> Thu, Oct 19, 2017 at 10:32:21PM CEST, yuvalm@mellanox.com wrote:
>>>>> Adding DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF permanent
>>>>> config
>>>>> parameter.  Defines number of MSI-X vectors allocated per VF.
>>>>> Value is permanent (stored in NVRAM), so becomes the new default
>>>>> value for this device.
>>>>
>>>> Sounds like you're having this enforce the same configuration for all child VFs.
>>>
>>> Yeah, this sounds like per-port config.
>> 
>> This opens old but lately silent discussion about introducing new port
>> types for different things. Like VF, dsa CPU port or dsa inter-chip
>> ports.
>
>FWIW, the "issue" with representing VF, DSA CPU port or DSA inter-chip
>port is that you would be representing a pipe, so there is obviously a
>question of whether your represent one end or both ends of that pipe,
>and how do you make sure both stay in sync if you represent those.
>
>For instance, for an inter-switch connection, I could decide to
>configure VLANs 1-3 tagged on one end of the connection, and forget to
>that on the other end of the connection, and that's just one example
>where things can go seriously wrong.

Certainly you have to represent both ends. So in your dsa inter-port
example, there should be onle devlink port instance for both dsa chips.


>
>> 
>>>
>>>
>>>>
>>>>>
>>>>> Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>>>>> Acked-by: Andy Gospodarek <gospo@broadcom.com>
>>>>> ---
>>>>>  include/uapi/linux/devlink.h | 1 +
>>>>>  1 file changed, 1 insertion(+)
>>>>>
>>>>> diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>>>>> index 8ad6c63..ef163b6 100644
>>>>> --- a/include/uapi/linux/devlink.h
>>>>> +++ b/include/uapi/linux/devlink.h
>>>>> @@ -260,6 +260,7 @@ enum devlink_perm_config_param {
>>>>>  	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
>>>>>  	DEVLINK_PERM_CONFIG_NUM_VF_PER_PF,
>>>>>  	DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT,
>>>>> +	DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF,
>>>>>  };
>>>>>
>>>>>  #endif /* _UAPI_LINUX_DEVLINK_H_ */
>>>>> --
>>>>> 2.7.4
>>>>
>
>
>-- 
>Florian
