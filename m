From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] Revert "bridge: only expire the mdb entry when
 query is received"
Date: Tue, 22 Oct 2013 09:13:43 -0400
Message-ID: <52667A07.4030303@redhat.com>
References: <1382223537-10844-1-git-send-email-linus.luessing@web.de>
	<20131021.184509.1933008514161772000.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	amwang@redhat.com
To: David Miller <davem@davemloft.net>, linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20131021.184509.1933008514161772000.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 10/21/2013 06:45 PM, David Miller wrote:
> From: Linus L=FCssing <linus.luessing@web.de>
> Date: Sun, 20 Oct 2013 00:58:57 +0200
>
>> While this commit was a good attempt to fix issues occuring when no
>> multicast querier is present, this commit still has two more issues:
>>
>> 1) There are cases where mdb entries do not expire even if there is a
>> querier present. The bridge will unnecessarily continue flooding
>> multicast packets on the according ports.
>>
>> 2) Never removing an mdb entry could be exploited for a Denial of
>> Service by an attacker on the local link, slowly, but steadily eating =
up
>> all memory.
>>
>> Actually, this commit became obsolete with
>> "bridge: disable snooping if there is no querier" (b00589af3b)
>> which included fixes for a few more cases.
>>
>> Therefore reverting the following commits (the commit stated in the
>> commit message plus three of its follow up fixes):
>>
>> ---
>> Revert "bridge: update mdb expiration timer upon reports."
>> This reverts commit f144febd93d5ee534fdf23505ab091b2b9088edc.
>> Revert "bridge: do not call setup_timer() multiple times"
>> This reverts commit 1faabf2aab1fdaa1ace4e8c829d1b9cf7bfec2f1.
>> Revert "bridge: fix some kernel warning in multicast timer"
>> This reverts commit c7e8e8a8f7a70b343ca1e0f90a31e35ab2d16de1.
>> Revert "bridge: only expire the mdb entry when query is received"
>> This reverts commit 9f00b2e7cf241fa389733d41b615efdaa2cb0f5b.
>> ---
>
> Cong, and other bridge folks, please review this revert.
>
t  http://vger.kernel.org/majordomo-info.html
>

Makes sense and make the implementation better follow the spec.
Looks like the issues seen before are resolved by the revert.

-vlad
