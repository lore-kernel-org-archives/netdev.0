From: jamal <hadi@cyberus.ca>
Subject: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 21 Mar 2005 08:14:50 -0500
Message-ID: <1111410890.1092.195.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>
	 <1107174142.8021.121.camel@jzny.localdomain>
	 <00c301c524b4$938cd240$6e69690a@RIMAS>
	 <1110379135.1091.143.camel@jzny.localdomain>
	 <1110416767.1111.76.camel@jzny.localdomain>
	 <025501c52552$2dbf87c0$6e69690a@RIMAS>
	 <1110453757.1108.87.camel@jzny.localdomain>  <423B7BCB.10400@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <423B7BCB.10400@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-18 at 20:09, Andy Furniss wrote:
> jamal wrote:
> > Hi Remus,
> > I could not reproduce this one - it is also a bit odd for calloc to
> > fail. I dont have iptables 1.3.1 but i will get and retry.
> > Does this happen all the time?
> 
> I get the same with iptables 1.3.1 and 1.3.0
> 
> iptables: calloc failed: Cannot allocate memory
> 
> using kernel 2.6.11.3 and tc iproute2-ss050314
> 
> If I try an earlier iptables (tested 9, 10, 11) I get
> 

Ok, I think i figured this one out as well - sorry dont have access to
my test hardware still to verify.

As i was suspecting this is related to iptables breaking backwards
compatibility. Starting with 1.3.0 the target structure changed ;->
(right at the top is a new field called version)
I suspect the iptables folks maybe unaware that there are other users of
iptables and assume that anyone needing to use new iptables will
recompile everything from scratch. BAD! BAD!
I am ccing the necessary evil doers (Harald and Patrick - at least they
would know who the real evildoer is). 

To test the theory copy iptables.h and iptables_common.h from
iptables-1.3.1/include into iproute2/include with the latest iproute2
and recompile. Make sure m_ipt.c is recompiled - you may have to do a 
make clean in iproute2/tc/

I should be able to validate all this stuff starting tommorow evening.
Also I have a feeling if you make this change, things will not work for
iptables <=1.2.9/10/11. Can you verify that?

cheers,
jamal
