From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] PKT_SCHED: Fix cls indev validation
Date: 22 Dec 2004 08:32:46 -0500
Message-ID: <1103722366.1089.75.camel@jzny.localdomain>
References: <20041219203050.GK17998@postel.suug.ch>
	 <41C68CEF.3030803@trash.net> <1103552215.1048.333.camel@jzny.localdomain>
	 <20041220200739.GX17998@postel.suug.ch> <41C7F833.4000909@trash.net>
	 <20041222003142.GB7884@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041222003142.GB7884@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-21 at 19:31, Thomas Graf wrote:
> * Patrick McHardy <41C7F833.4000909@trash.net> 2004-12-21 11:17
> > Could you make your patchset available somehow ?
> 
> http://people.suug.ch/~tgr/patches/queue/
> 
> Unfinished and untested.

I just took a quick glimpse. 

1)Recall: Policer will have to die at some point - only reason for its
existence is for backward compat.
New iproute2 code sooner than later stop using that inteface so we can
kill it. I suspect we can kill it in a year or two and definetely the
day 2.7 comes out.

2) The name tcf_attrs doesnt sound right - attributes are normally
data pieces not methods. Cant think of a good name.

3) What can i say? dang - this indev thing is getting out of control ;->
If you are going to go this far for beautification sake then
kill the .indev thing please before it becomes a beast. Do what we
discussed a while back:
- have a generic very basic extended generic match API which indev uses
that gets invoked from  the classifier. It should take no more than one
page to write the indev extension - if it exceeds that you are doing
something wrong. There should be capability to mix and match these
extenders so i can say in u32 something like:
 match ip src X
 match extend indev src eth0
 match protocol tcp
 match extended metadata fwmark 0x10

etc.

I think its time we did this right than defering.

Of course all backward compatibility rules apply ;->

cheers,
jamal
