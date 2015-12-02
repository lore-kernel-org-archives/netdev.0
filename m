From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 4/6] mlxsw: core: Implement temperature hwmon
 interface
Date: Wed, 2 Dec 2015 23:25:52 +0100
Message-ID: <20151202222551.GP2355@nanopsycho.orion>
References: <1448628359-20077-1-git-send-email-jiri@resnulli.us>
 <1448628359-20077-5-git-send-email-jiri@resnulli.us>
 <CAJ3xEMgUt4a-Mq8DO0a_Vm-UYJsHsrxYyGh23=rSAiZ12S9oGQ@mail.gmail.com>
 <20151129104918.GC2194@nanopsycho.orion>
 <CAJ3xEMhGv9nTq+CtpX=e4E+4WpipVnc---EUOEqxJ06xOSBsog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37264 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756751AbbLBWZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 17:25:54 -0500
Received: by wmww144 with SMTP id w144so76782287wmw.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 14:25:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMhGv9nTq+CtpX=e4E+4WpipVnc---EUOEqxJ06xOSBsog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 02, 2015 at 11:05:48PM CET, gerlitz.or@gmail.com wrote:
>On Sun, Nov 29, 2015 at 12:49 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Sun, Nov 29, 2015 at 10:04:07AM CET, gerlitz.or@gmail.com wrote:
>>>[..]
>>>> +enum mlxsw_hwmon_attr_type {
>>>> +       MLXSW_HWMON_ATTR_TYPE_TEMP,
>>>> +       MLXSW_HWMON_ATTR_TYPE_TEMP_MAX,
>>>> +};
>>>> +
>>>> +static void mlxsw_hwmon_attr_add(struct mlxsw_hwmon *mlxsw_hwmon,
>>>> +                                enum mlxsw_hwmon_attr_type attr_type,
>>>> +                                unsigned int type_index, unsigned int num) {
>>>> +       struct mlxsw_hwmon_attr *mlxsw_hwmon_attr;
>>>> +       unsigned int attr_index;
>>>> +
>>>> +       attr_index = mlxsw_hwmon->attrs_count;
>>>> +       mlxsw_hwmon_attr = &mlxsw_hwmon->hwmon_attrs[attr_index];
>>>> +
>>>> +       switch (attr_type) {
>>>> +       case MLXSW_HWMON_ATTR_TYPE_TEMP:
>>>> +               mlxsw_hwmon_attr->dev_attr.show = mlxsw_hwmon_temp_show;
>>>> +               mlxsw_hwmon_attr->dev_attr.attr.mode = S_IRUGO;
>>>> +               snprintf(mlxsw_hwmon_attr->name, sizeof(mlxsw_hwmon_attr->name),
>>>> +                        "temp%u_input", num + 1);
>>>> +               break;
>>>> +       case MLXSW_HWMON_ATTR_TYPE_TEMP_MAX:
>>>> +               mlxsw_hwmon_attr->dev_attr.show = mlxsw_hwmon_temp_max_show;
>>>> +               mlxsw_hwmon_attr->dev_attr.attr.mode = S_IRUGO;
>>>> +               snprintf(mlxsw_hwmon_attr->name, sizeof(mlxsw_hwmon_attr->name),
>>>> +                        "temp%u_highest", num + 1);
>>>> +               break;
>>>> +       default:
>>>> +               BUG();
>>>
>>> Guys, do we really have to crash the whole system just b/c somehow an
>>> unknown value propagated here during **init** time?
>>>
>>> I don't think so.
>
>> "default" case simply *cannot* happen. If it happens, it is a stack
>> corruption or some other fatal problem. I believe that BUG is
>> appropriate at these cases.
>
>Jiri, as Dave commented today on the LAG series,  BUG_ON() is bad and
>is only to ever be used when the kernel's continued operation is
>absolutely impossible, can we change here to WARN_ON() or a like?

In this case, I don't know how to bail out correctly, I believe that
bugon is correct here.

Again, there is no possible way to achieve this bugon, other than a
stack corruption. I don't think we should try to cope with a stack
corruption.

Feel free to send a patch if you think otherwise.

Thanks.
