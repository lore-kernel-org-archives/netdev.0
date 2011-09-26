From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] net: change capability used by socket options IP{,V6}_TRANSPARENT
Date: Mon, 26 Sep 2011 09:31:21 -0700
Message-ID: <4E80A8D9.4050405@schaufler-ca.com>
References: <1315927629.5851.4.camel@bzorp> <1316734189-26668-1-git-send-email-zenczykowski@gmail.com> <4E7CB5A9.2020303@schaufler-ca.com> <CAHo-OozcFULbDBHoWsQPoun-HAaHLBM=pRzMJjsv1cJF77zSYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Casey Schaufler <casey@schaufler-ca.com>
To: =?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <zenczykowski@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAHo-OozcFULbDBHoWsQPoun-HAaHLBM=pRzMJjsv1cJF77zSYg@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/23/2011 12:33 PM, Maciej =C5=BBenczykowski wrote:
>> Under what circumstances would a process that requires the
>> new capability not require CAP_NET_ADMIN? Is there a real
>> case where a process would be expected to require only this
>> new capability? Adding new capability values is somewhat
>> perilous and the granularity you are proposing, that of
>> controlling a single bit, would explode the list of
>> capabilities into the hundreds if it were applied throughout
>> the kernel.
> CAP_NET_ADMIN is a huge hammer, it allows one to totally
> reconfigure the networking subsystem.
>
> In a containerized multi-user/job environment, you do not want
> something like an instance of a load-balanced web server, proxy
> or dns server being able to do that - policy/configuration decisions
> should be left up to the administrator and/or machine management
> daemon(s).  Each of these can make use of transparent sockets
> (in various ways, mostly in coordination with large scale load balanc=
ing).
>
> You also do not want one user running in one container being able
> to sniff (CAP_NET_RAW) traffic from another user (hence CAP_NET_RAW
> isn't an acceptable substitute).
>
> One could conceivably use network namespaces for seperation, but
> in this particular case they are _way_ too overkill (and also add too
> much overhead).
>
> This might be *just* a single bit in the socket, but this bit effecti=
vely
> controls whether you can do certain types of privileged operations
> on the socket in question - and it gets tested in various places thro=
ughout
> the networking stack.
>
> Hopefully, this answers your question.

It is an important argument, but no, it does not address my issue.
The problem is that you can make that same argument for breaking up
just about every capability. CAP_SYSADMIN could easily be broken into
a hundred separate capabilities and CAP_NET_ADMIN, as you point out,
into dozens. My point is that with the potential to create so many
capabilities, what makes this particular action so much more important
than the other things already covered by CAP_NET_ADMIN?

If we introduce dozens of new capabilities we will end up with
the exact same problem that has been so clearly demonstrated
by the SELinux reference policy. Excessive granularity will kill
and security facility. Capabilities are already more granular than
most people are comfortable with.

=46or a facility to warrant a new capability it must be completely
unreasonable to fit it into an existing capability, sufficiently
general in its use that the bit won't show up unused when networking
fashions change in a year or two, and it needs to protect something
that is obviously very important. You have a variant of a somewhat
obscure facility that will only be used in edge cases in support
of an unproven (if promising) technology that is targeted to a
disappearing use case.

>
> - Maciej
> --
> To unsubscribe from this list: send the line "unsubscribe linux-secur=
ity-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
