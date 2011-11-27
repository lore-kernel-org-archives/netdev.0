From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Sun, 27 Nov 2011 03:28:08 -0600
Message-ID: <20111127092808.GE21635@elie.hsd1.il.comcast.net>
References: <4E82C0B5.1050902@wolke7.net>
 <1317254171.4068.12.camel@deadeye>
 <20111124044137.GA18262@elie.hsd1.il.comcast.net>
 <4ECFE7A7.5070300@wolke7.net>
 <20111125201936.GA26692@elie.hsd1.il.comcast.net>
 <1322253122.2550.3.camel@edumazet-laptop>
 <20111125222211.GA13719@electric-eye.fr.zoreil.com>
 <1322262357.2550.12.camel@edumazet-laptop>
 <20111126004447.GA14744@electric-eye.fr.zoreil.com>
 <1322280423.10212.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	Armin Kazmi <armin.kazmi@tu-dortmund.de>,
	Gerd <booster@wolke7.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1322280423.10212.3.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le samedi 26 novembre 2011 =C3=A0 01:44 +0100, Francois Romieu a =C3=A9=
crit :

>> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethe=
rnet/realtek/r8169.c
>> index 6f06aa1..54be9e1 100644
>> --- a/drivers/net/ethernet/realtek/r8169.c
>> +++ b/drivers/net/ethernet/realtek/r8169.c
>> @@ -5820,8 +5820,7 @@ static irqreturn_t rtl8169_interrupt(int irq, =
void *dev_instance)
>>  			case RTL_GIGA_MAC_VER_11:
>>  			case RTL_GIGA_MAC_VER_22:
>>  			case RTL_GIGA_MAC_VER_26:
>> -				netif_stop_queue(dev);
>> -				rtl8169_tx_timeout(dev);
>> +				rtl8169_schedule_work(dev, rtl8169_reset_task);
>>  				goto done;
>>  			/* Testers needed. */
>>  			case RTL_GIGA_MAC_VER_17:
>
> Please Jonathan, Gerd, try this fix !

Thanks, Eric.  Unfortunately I don't have the hardware.

Gerd, would you be able to try this patch?  It works like this:

  apt-get install git build-essential
  git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linu=
x.git
  cd linux
  ... apply the fix, for example using "patch -p1" ...
  make localmodconfig; # minimal configuration
  make deb-pkg
  dpkg -i ../<name of package>
  reboot

=46eel free to email me privately if you have any questions.

Regards,
Jonathan
