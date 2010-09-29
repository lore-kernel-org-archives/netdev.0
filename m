From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH v2 1/2] Phonet: Implement Pipe Controller to support Nokia Slim Modems
Date: Wed, 29 Sep 2010 21:21:17 +0300
Message-ID: <201009292121.18274.remi.denis-courmont@nokia.com>
References: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com> <201009290125.07068.remi.denis-courmont@nokia.com> <20100929063219.GA18733@bnru01.bnr.st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "STEricsson_nomadik_linux" <STEricsson_nomadik_linux@list.st.com>,
	Sudeep DIVAKARAN <sudeep.divakaran@stericsson.com>,
	Gulshan KARMANI <gulshan.karmani@stericsson.com>,
	Linus WALLEIJ <linus.walleij@stericsson.com>
To: ext Kumar SANGHVI <kumar.sanghvi@stericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:24699 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926Ab0I2SUu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 14:20:50 -0400
In-Reply-To: <20100929063219.GA18733@bnru01.bnr.st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wednesday 29 September 2010 09:32:20 ext Kumar SANGHVI, you wrote:
> We can introduce corrections in Phonet stack for the PS path which
> would be minor. But then those changes look more like a hack. Further=
,
> this change would be required at several places where PS communicatio=
n
> is happening with modem e.g. pep_reply, pipe_skb_send, pipe_snd_statu=
s,
> etc.
>=20
> Further, if a new function tomorrow is introduced for PS path
> communication with modem then, that hack will have to be added to tha=
t
> function also.

It seems to me that you really want to implement the connect() socket c=
all, so=20
that one of the two endpoints will stand up for the missing controller.=
 That's=20
still much cleaner than CREATE and DESTROY ioctl()'s.

Besides, the pipe should be destroyed when the last socket descriptor i=
s=20
closed anyway. So ioctl(DESTROY) really seems like a bad idea to me.

Similarly, ENABLE and DISABLE should be revectored into a boolean socke=
t=20
option.

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
