From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Tue, 8 Mar 2016 18:16:48 +0100
Message-ID: <56DF0900.6090906@hartkopp.net>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56DC1561.9060306@hartkopp.net>
 <SG2PR06MB10386D712BC8C345DF726523C3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DD36F5.2000308@pengutronix.de>
 <SG2PR06MB1038DD47FAFF354C99AF2E4FC3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DE8345.50901@hartkopp.net>
 <SG2PR06MB1038B71C7921984611F72CF5C3B20@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DEC49D.4@hartkopp.net>
 <SG2PR06MB10388F87746A1191E51B199FC3B20@SG2PR06MB1038.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <SG2PR06MB10388F87746A1191E51B199FC3B20@SG2PR06MB1038.apcprd06.prod.outlook.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/08/2016 01:48 PM, Ramesh Shanmugasundaram wrote:

>> In fact you provided a CAN driver which is "CAN-FD-only".
> 
> Yes. That's the status of current submission.
> 
>> We did not had that before but there's a solution for this kind of setup.
>>
>> There is a similar case with CAN_CTRLMODE_FD_NON_ISO we had on the M_CAN
>> driver which only provides non-ISO configuration for the supported IP core
>> and _no_ option to _change_ this value:
>>
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id
>> =6cfda7fbebe8a4fd33ea5722fa0212f98f643c35
>>
>> If you would do it similar in rcar_canfd.c with
>>
>> /* CAN_CTRLMODE_FD is fixed with R-Car CAN FD */
>> priv->can.ctrlmode = CAN_CTRLMODE_FD;
>>
>> and remove CAN_CTRLMODE_FD from the priv->can.ctrlmode_supported
>> assignment then it should do the entire configuration process correctly
>> for you.
>> Including the proper tests for the two bitrates.
>> (see open_candev() in linux/drivers/net/can/dev.c)
>>
>> Right?
> 
> I did try this option earlier but there are two problems with this method.
> 
> 1) Below configuration is not possible
> 
> ip link set can0 up type can bitrate 1000000 dbitrate 1000000 fd on
> 
> "fd on" -> This is not allowed because CAN_CTRLMODE_FD bit is not set in ctrlmode_supported.
> 
> 2) If I ignore "fd on", my interface MTU stays as CAN_MTU only. If I have to change the MTU alone to CANFD_MTU using another netlink message, it again checks ctrlmode_supported where it would fail. I have the option of providing my own change_mtu function & ignore this check but two configuration messages are required for my driver alone :-(.
> 
> Both these anomalies are addressed with the current check I have. 

Oh - you are right with complaining about this inconsistency.

Can you check my RFC patch for Linux stable I just sent on the mailing list?
http://marc.info/?l=linux-can&m=145745724917976&w=2

Many thanks,
Oliver
