From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/isdn: break out of the loop after call isdn_tty_send_msg
Date: Fri, 15 Mar 2013 10:02:28 +0800
Message-ID: <51428134.50601@asianux.com>
References: <512DD2B3.2070404@asianux.com> <512DD94C.2020008@suse.cz> <512EC79C.3010700@asianux.com> <512F296E.1050303@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:31026 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753409Ab3COCCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 22:02:55 -0400
In-Reply-To: <512F296E.1050303@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Maintainers:

  is it qualified to be applied ?

  thanks.


=E4=BA=8E 2013=E5=B9=B402=E6=9C=8828=E6=97=A5 17:54, Jiri Slaby =E5=86=99=
=E9=81=93:
> On 02/28/2013 03:57 AM, Chen Gang wrote:
>>
>>   need break out of the loop after call isdn_tty_send_msg.
>>     isdn_tty_send_msg is intended to eat the rest of the string.
>>     so need not scan again the string which appended "+M...".
>=20
> Yes, looks good.
>=20
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> ---
>>  drivers/isdn/i4l/isdn_tty.c |    4 +++-
>>  1 files changed, 3 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty=
=2Ec
>> index d8a7d83..8ac7b33 100644
>> --- a/drivers/isdn/i4l/isdn_tty.c
>> +++ b/drivers/isdn/i4l/isdn_tty.c
>> @@ -3587,7 +3587,7 @@ isdn_tty_parse_at(modem_info *info)
>>  			case 'M':	/* MESSAGE */
>>  				p++;
>>  				isdn_tty_send_msg(info, m, p);
>> -				break;
>> +				goto tail;
>>  			default:
>>  				PARSE_ERROR;
>>  			}
>> @@ -3601,6 +3601,8 @@ isdn_tty_parse_at(modem_info *info)
>>  			PARSE_ERROR;
>>  		}
>>  	}
>> +
>> +tail:
>>  #ifdef CONFIG_ISDN_AUDIO
>>  	if (!info->vonline)
>>  #endif
>>
>=20
>=20


--=20
Chen Gang

Asianux Corporation
