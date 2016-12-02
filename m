From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Fri, 2 Dec 2016 16:19:53 +0100
Message-ID: <5627300c-a9b5-8709-bb08-5f0bceddfb05@st.com>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd> <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd> <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
 <20161202123241.GA5869@amd> <c4748c8f-ae4b-9bbc-7d20-9c7b7ce433c8@st.com>
 <5db2ce3e-d4eb-d5d0-594c-8cd0f2e70476@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Alexandre Torgue <alexandre.torgue@st.com>,
        Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5db2ce3e-d4eb-d5d0-594c-8cd0f2e70476@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alex

On 12/2/2016 3:26 PM, Alexandre Torgue wrote:
>> 4.4 has no GMAC4 support.
>> Alex, do you remember any patches to fix that?
>
> No sorry Peppe.
>
> Pavel,
>
> Sorry but I'm a little bit confused. I'm dropped in some mails without
> historic. I see cleanup, coalescence issue and TSO question.
> What is your main issue? Are you working on gmac4 or 3.x ?
> Can you refresh a little bit the story please ?

let me try to do a sum, please Pavel feel free to correct me.

There are some open points about the tx mitigation schema
that we are trying to detail and eventually tune or change
(but keeping the same performance on other user-case).

In particular, the test case that is raising problem is
an unicast tx bench.
I suggested Pavel to tune coalesce (IC bit settings) via
ethtool and monitor stats but he is getting problems (maybe
due to lock).

IIUC problems are mainly on new kernel and not on 4.4 where
the gmac4 is missing. Please Pavel, could you confirm?

Then, there are some open points about lock protections
for xstat and Pavel is getting some problem on SMP.
I do think that we need to review that. This also could
improve the code in critical parts.

Also there are some other discussion about the lock
protection on NAPI still under discussion. I have not
clear if in this case Pavel is getting strange behavior.

Regards
Peppe
