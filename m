From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH tty-next 15/22] isdn: tty: Use private flag for ASYNC_CLOSING
Date: Mon, 16 Jun 2014 17:01:28 -0400
Message-ID: <539F5B28.9080000@hurleysoftware.com>
References: <1402924639-5164-1-git-send-email-peter@hurleysoftware.com> <1402924639-5164-16-git-send-email-peter@hurleysoftware.com> <063D6719AE5E284EB5DD2968C1650D6D1725D13A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-serial@vger.kernel.org" <linux-serial@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Karsten Keil <isdn@linux-pingi.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725D13A@AcuExch.aculab.com>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 06/16/2014 11:37 AM, David Laight wrote:
> From: Of Peter Hurley
>> ASYNC_CLOSING is no longer used in the tty core; use private flag
>> info->closing as substitute.
> ...
>> @@ -311,6 +311,7 @@ typedef struct atemu {
>>   typedef struct modem_info {
>>     int			magic;
>>     struct tty_port	port;
>> +  int			closing:1;	 /* port count has dropped to 0    */
>>     int			x_char;		 /* xon/xoff character             */
>>     int			mcr;		 /* Modem control register         */
>>     int                   msr;             /* Modem status register          */
>
> That should probably be a bool and set to true/false.
> You are probably adding a load of padding.

struct modem_info is over 1K, with several existing int-as-bool fields.
An array of 64 struct modem_info are statically allocated with every isdn device.

It doesn't look like memory consumption has been a consideration with the isdn driver.

Regards,
Peter Hurley
