From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: make ctl_path local and const
Date: Tue, 19 Oct 2010 21:59:39 -0700
Message-ID: <1287550779.10409.620.camel@Joe-Laptop>
References: <1287543276-4511-1-git-send-email-xiaosuo@gmail.com>
	<1287543701.10409.599.camel@Joe-Laptop>
	<AANLkTi=pz4zYnnUSvb9FjVvCAURruHhJTz7pBKDi8Pdw@mail.gmail.com>
	<1287545337.10409.602.camel@Joe-Laptop>
	<AANLkTimGUB-+TTsje1kc3q9PyoB2jJdgCK2Z7n9u7N1J@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy Grover <andy.grover@oracle.com>, James Morris <jmorris@namei.org>,
        linux-sctp@vger.kernel.org, rds-devel@oss.oracle.com,
        "Pekka Savola \(ipv6\)" <pekkas@netcore.fi>, linux-x25@vger.kernel.org,
        dccp@vger.kernel.org, bridge@lists.linux-foundation.org,
        Andrew@smtp1.linux-foundation.org, coreteam@netfilter.org,
        Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Joerg Reuter <jreuter@yaina.de>, Sridhar Samudrala <sri@us.ibm.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        Vlad Yasevich <vladislav.yasevich@hp.com>, netfilter@vger.kernel.org,
        Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
        linux-hams@vger.kernel.org,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, linux-kernel@vger.ker
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <AANLkTimGUB-+TTsje1kc3q9PyoB2jJdgCK2Z7n9u7N1J@mail.gmail.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-10-20 at 12:52 +0800, Changli Gao wrote:
> On Wed, Oct 20, 2010 at 11:28 AM, Joe Perches <joe@perches.com> wrote:
> > At least some objects are smaller with static.
> > $ size net/appletalk/sysctl_net_atalk.o.*
> >   text    data     bss     dec     hex filename
> >    324     236      48     608     260 net/appletalk/sysctl_net_atalk.o.withstatic
> >    344     236      48     628     274 net/appletalk/sysctl_net_atalk.o.withoutstatic
> I got the opposite result for the size of the whole kernel image with
> allyesconfig.
> original: 33531456
> patched: 33531424
> It seems random.

Not using static requires the compiler to emit
initialization code for any use of the routine
that otherwise would only be done once.
