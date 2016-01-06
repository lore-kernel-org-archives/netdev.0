From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible) division by zero
Date: Wed, 06 Jan 2016 18:50:24 +0200
Message-ID: <DDC4BD3D-A5F5-4EBF-8461-7C63ABC9F852@natalenko.name>
References: <26396443.iDTTxgChSj@spock> <CAK6E8=d1FquYTtMXi6v+koruRhA2MUe693-DX5jbU8urRatUoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK6E8=d1FquYTtMXi6v+koruRhA2MUe693-DX5jbU8urRatUoQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unfortunately, the patch didn't help -- I've got the same stacktrace wi=
th slightly different offset (+3) within the function.

Now trying to get full stacktrace via netconsole. Need more time.

Meanwhile, any other ideas on what went wrong?


On December 22, 2015 4:10:32 AM EET, Yuchung Cheng <ycheng@google.com> =
wrote:
>On Mon, Dec 21, 2015 at 12:25 PM, Oleksandr Natalenko
><oleksandr@natalenko.name> wrote:
>> Commit 3759824da87b30ce7a35b4873b62b0ba38905ef5 (tcp: PRR uses CRB
>mode by
>> default and SS mode conditionally) introduced changes to
>net/ipv4/tcp_input.c
>> tcp_cwnd_reduction() that, possibly, cause division by zero, and
>therefore,
>> kernel panic in interrupt handler [1].
>>
>> Reverting 3759824da87b30ce7a35b4873b62b0ba38905ef5 seems to fix the
>issue.
>>
>> I'm able to reproduce the issue on 4.3.0=E2=80=934.3.3 once per seve=
ral day
>> (occasionally).
>>
>> What could be done to help in debugging this issue?
>Do you have ECN enabled (i.e. sysctl net.ipv4.tcp_ecn > 0)?
>
>If so I suspect an ACK carrying ECE during CA_Loss causes entering CWR
>state w/o calling tcp_init_cwnd_reduct() to set tp->prior_cwnd. Can
>you try this debug / quick-fix patch and send me the error message if
>any?
>
>
>>
>> Regards,
>>   Oleksandr.
>>
>> [1] http://i.piccy.info/
>>
>i9/6f5cb187c4ff282d189f78c63f95af43/1450729403/283985/951663/panic.jpg

--=20
Sent from my Android device with K-9 Mail. Please excuse my brevity.
