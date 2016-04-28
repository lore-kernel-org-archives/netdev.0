From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC 07/20] net: dsa: list ports in switch\\
Date: Thu, 28 Apr 2016 14:18:53 -0400
Message-ID: <871t5pr3zm.fsf@ketchup.mtl.sfl>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1461796217-18893-8-git-send-email-vivien.didelot@savoirfairelinux.com> <20160427231537.GJ29024@lunn.ch> <572241BB.1070304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <572241BB.1070304@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 27/04/16 16:15, Andrew Lunn wrote:
>> On Wed, Apr 27, 2016 at 06:30:04PM -0400, Vivien Didelot wrote:
>>> List DSA port structures in their switch structure, so that drivers can
>>> iterate on them to retrieve information such as their ports membership.
>> 
>> And this would be so much easier using a plan array.
>
> Agreed, I do not see much value in doing this at the moment. Even if you
> have unused ports in a switch, allocating an array is a small price to
> pay compared to directly indexing by port number.
>
> NAK from me unless there is a compelling reason for doing so.

The point of having a list is 1) get rid of the DSA_MAX_PORTS and have
variable number of ports 2) lists make iteration easier with variable
number of switchs/ports, e.g.:

    dsa_tree_for_each_switch(dst, ds)
        dsa_switch_for_each_port(ds, dp)
            /* do something with the port */;

Anyway, I'm writing a proposal for a new design of DSA, in order to
support the D in DSA. That way, we'll avoid reviewing details of the
implementation and have a big picture of the necessary API changes.

Thanks,

        Vivien
