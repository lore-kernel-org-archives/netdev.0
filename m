From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: introduce simple actions
Date: Sun, 20 Mar 2005 20:58:30 +0100
Message-ID: <423DD5E6.2020708@trash.net>
References: <1111345551.1095.82.camel@jzny.localdomain>	 <423DCD8C.6030100@trash.net> <1111347345.1094.98.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Thomas Graf <tgraf@suug.ch>
To: hadi@znyx.com
In-Reply-To: <1111347345.1094.98.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim wrote:
> On Sun, 2005-03-20 at 14:22, Patrick McHardy wrote:
>
>>One of the next things I wanted to do in this area was
>>moving all the large inline functions to act_generic.c,
>>so if possible I would prefer not to put these in a header
>>file.
> 
> These are small functions. Take a look at the simple action i attached.
> If you can give me the same functionality and still move things
> de_inlined to act_generic.c i would be fine with it.

The functions are not inlined anyway, so the question is whether any
#define magic is done as with pkt_act.h, otherwise there is no reason
to have them in a header file. Looking at your patch, it seems
tc_defact.h uses the redefined pkt_act.h functions, so it does need to
be in a header file, but frankly, I find this horrible. The patch
doesn't conflict with cleanup of pkt_act.h, but it means more work when
doing it, so I think this is what should be done first. Especially
since this is only an example, not useful for users, but it will be
possibly used to create more actions that also need to be changed
afterwards.

Regards
Patrick
