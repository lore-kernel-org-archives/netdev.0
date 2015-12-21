From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: [REGRESSION] tcp/ipv4: kernel panic because of (possible) division by zero
Date: Mon, 21 Dec 2015 22:25:30 +0200
Message-ID: <26396443.iDTTxgChSj@spock>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 3759824da87b30ce7a35b4873b62b0ba38905ef5 (tcp: PRR uses CRB mode=
 by=20
default and SS mode conditionally) introduced changes to net/ipv4/tcp_i=
nput.c=20
tcp_cwnd_reduction() that, possibly, cause division by zero, and theref=
ore,=20
kernel panic in interrupt handler [1].

Reverting 3759824da87b30ce7a35b4873b62b0ba38905ef5 seems to fix the iss=
ue.

I'm able to reproduce the issue on 4.3.0=E2=80=934.3.3 once per several=
 day=20
(occasionally).

What could be done to help in debugging this issue?

Regards,
  Oleksandr.

[1] http://i.piccy.info/
i9/6f5cb187c4ff282d189f78c63f95af43/1450729403/283985/951663/panic.jpg
