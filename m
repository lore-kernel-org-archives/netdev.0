From: Holger Schurig <holgerschurig@gmail.com>
Subject: Re: [PATCH 2/3] can: fix oops caused by wrong rtnl dellink usage
Date: Tue, 28 Jun 2016 09:36:57 +0200
Message-ID: <874m8d7oiu.fsf@gmail.com>
References: <1466673741-23115-1-git-send-email-mkl@pengutronix.de> <1466673741-23115-3-git-send-email-mkl@pengutronix.de> <e092c3e9-56f3-f765-a9ef-89697ec46e16@cogentembedded.com> <0e51107f-a381-6c94-0079-d0ed415d8bcc@hartkopp.net> <f4b685f9-a2ad-d3cc-1204-f457705467df@cogentembedded.com> <a1bd95b5-ea93-0e99-7784-dad393240f06@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, stable@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <a1bd95b5-ea93-0e99-7784-dad393240f06@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> static void can_dellink(struct net_device *dev, struct list_head *head);
>
> and
>
> static void can_dellink(struct net_device *dev, struct list_head *head)
> {
> 	return;
> }

Wouldn't the canonical form be this:

static void can_dellink(struct net_device *dev, struct list_head *head)
{
}


- the curly braces make sure this isn't a forward definition
- but no useless return either


But then again, this "return" is only cosmetical. No compiler will
generate any code from it.
