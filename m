From: jamal <hadi@cyberus.ca>
Subject: Re: path: module replay
Date: 19 Jan 2005 08:35:07 -0500
Message-ID: <1106141706.1048.953.camel@jzny.localdomain>
References: <1105900522.1090.798.camel@jzny.localdomain>
	 <41EAB74F.6060507@trash.net>  <20050116185630.GZ26856@postel.suug.ch>
	 <1105903033.1097.829.camel@jzny.localdomain>
	 <1105903960.1097.836.camel@jzny.localdomain>  <41EDE15B.40300@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41EDE15B.40300@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-18 at 23:26, Patrick McHardy wrote:
> jamal wrote:
> 
> >Ok, here is the last patch. I think module replay should be done from
> >that spot and to be consistent as well from cls_api.c for legacy stuff.
> >I also fixed a module ref count leak. 
> >the act_api piece is dependent on what i sent earlier for namsiz.
> >the cls_api change i believe conflicts with what Thomas sent yesterday.
> >
> +replay:
>                 act = tcf_action_init_1(tb[i], est, name, ovr, bind, err);
> -               if (act == NULL)
> -                       goto err;
> +               if (act == NULL) {
> +                       if (*err == -EAGAIN)
> +                               goto replay;
> +                       goto err_out;
> +               }
> 
> This part is wrong. 

And we exchanged emails on this topic already in private and you said 
you will fix and send out the patch;-> So please do just that or you can
wait until i have more time and my hardware at the same spot.

cheers,
jamal
