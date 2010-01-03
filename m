From: Peter Dolding <oiaohm@gmail.com>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Sun, 3 Jan 2010 11:43:46 +1000
Message-ID: <e7d8f83e1001021743ie495e3ctcc823a58f36c43d5@mail.gmail.com>
References: <551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	 <20091231175257.GA7210@us.ibm.com>
	 <551280e50912311020x2bdc5b1o699a601f67b91662@mail.gmail.com>
	 <m1aawzm1tc.fsf@fess.ebiederm.org>
	 <20100101144300.023f47a5@lxorguk.ukuu.org.uk>
	 <m1zl4x4wq8.fsf@fess.ebiederm.org> <4B3E6A8B.7060705@schaufler-ca.com>
	 <20100101223919.00b60938@lxorguk.ukuu.org.uk>
	 <e7d8f83e1001011642g3b642ca8ua255947c44049fcf@mail.gmail.com>
	 <4B3FB0FC.3030809@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Andrew G. Morgan" <morgan@kernel.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Bryan Donlan <bdonlan@gmail.com>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752287Ab0ACBnv@vger.kernel.org>
In-Reply-To: <4B3FB0FC.3030809@schaufler-ca.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 3, 2010 at 6:47 AM, Casey Schaufler <casey@schaufler-ca.com=
> wrote:
> Peter Dolding wrote:
>> ...
>
> If you are using SELinux application developers need to know
> what the policy of the system they are using is or they need
> to know that any operation may fail for reasons mysterious to
> the developer and that the programs needs to be coded accordingly.

Again how can application developers do this releasing on many
different distrobutions in a cost effective way.

Yes application developer can code to cope with operations may fail
for mysterious.   But again you over look the poor end user who the
application just failed to work right for.   The Application maker
gets rightly or wrong tared and feathered for applications failing to
perform tasks.
>
>> To an application developers.
>> 1) Mandatory access controls that relate to what the application nee=
d
>> to do is of interest.
>> 2) mandatory integrity controls that relate to what the application
>> needs protected of interest.
>>
>
> Right. And with SELinux there is no way for an application to
> determine from readily available information whether an action
> is appropriate. This is not a failing of the LSM, it is a well
> known and often discussed characteristic of SELinux.
>
It is a failing of LSM.  Where is the framework providing such a
feature to applications in a LSM neutral way.  Since such a framework
does not exist there is no pressure on LSM's to support it.  Of course
SELinux could go on disregarding the hooks but then more applications
developers would be recommending other LSM frameworks that support
them.

Ie if SELinux wants to keep market share they would be force to lift ga=
me.

This is the problem you are not seeing you have 4 different sets of
people LSM's have to interact with.

1) LSM developers.  The current framework is good for them.
2) Application Developers.   Current framework completely suxs there
is nothing in it for them to make there live easy.
3) Administrators.   Ok can be made do most of what they want but is
insane to add applications to a LSM that don't have a preexisting
profile.  Or you end up running items like Apparmor that really don't
secure the application correctly to avoid.  Basically it suxs for
these guys as well.   Since its either waste hours or do there job
poorly.
4) The poor end user having application magically fail due to secuirty
system configuration being wrong.  Suxs for these people as well.

Earlier here you went into upper level policy information like
passwords and the like.

I am not talking upper level policy.  I am talking low level part of
the policy engine give to the application developers.  Will make their
life more tolerable.  Applications may have there own policy engine
inside ie good examples mysql and postgresql they have there own
security engines inside.  So if they want to do upper level policy
they can by there own engine.  They just need access to the settings
of raw LSM hooks somehow to enforce it.  Basically we are not talking
normal LSM module policies here.   Application developers have no
reason to have any interest in LSM normal policies they are not a
usable tool to them.  Instead LSM normal polices are just a pain in
the but that cause applications to fail on there users in strange and
unpredictable ways.

I am not talking about applications controling application to
application policy here other than direct execution.  Like accessing
system wide password data that is application to application policy.
That is not normally the worry of Application developers.  Application
developers would just list they need access to particular applications
to operate like getent to look up global user information.

Other thing is provide application developers a way of providing a
list of LSM monitored points that it needs to pass to operate
completely.  Like required files, network access, root rights and so
on this is what I would call Application secuirty data.

Administrator can use this Application secuirty data to confirm if or
if not the LSM will allow application to operate correctly.   So the
poor end user does not have application fail to perform a task they
need.   Also having a list of everything the application needs to
operate could be used to access the secuirty risk of an application
even before it is first run.  Useful for when Administrator has to
pick between two different applications todo task.

Application secuirty data could also be processed by LSM to produce
basic profiles that work.

Now of course I know this kind of data is going to go against your
grain Casey Schaufler because it will not be simple.  Everything the
LSM hooks could control that the application is planing to come into
contact with would be listed.

Its one of the largest things that makes SELinux policies unworkable.
 But that is lack of clean seperation between user and application
data.   Complexity is required here so no more than what application
needs is granted.   Application developers don't have a issue with
complexity if they can do it once for everything.

Capabilities have improved secuirty because application developers can
control them in a dependable way.   Now I don't think the idea of
allowing Capabilities to control every single LSM hook directly would
go down well.   For configurable items like if or if not access to a
particular file is allowed Capabilities cannot do it.   API limitation
not flexible enough.

Serious question.  If we attempted to make a generic application mac
enforcement engine.  Number 1 is it possible?    Number two how many
hooks would be required into the engine to allow same flexablity as
current day LSM modules has?

I think it would be possible.  And I don't think there would be many
hooks required.
1) File access hook to handle the different ways LSM store file access.
2) Notifcation hook to inform LSM of a event it flaged.
3) Execute Hook to setup engines processing.

Engine could take care of auto termination of applications and the
like.    A single engine that can handle all hooks would basically
follow the model of iptables.   It can be configured any way LSM
choose.

LSM goal is to be generic.  Part of that goal should be to make LSM's
more generic reducing down the differences between LSM modules.

>>
>> The simple problem here is that SELinux along with Smack and others
>> because its too complex with too many variables making its config
>> files too hard for applications makers to release ones that work.
>>
>
> You are inappropriately painting SELinux and Smack with the same brus=
h.
> Addressing this complexity was a design goal of Smack and while the
> addition of any MAC scheme will require additional attention by the
> application developer at least it is possible to do so with Smack.
> SELinux embraces the "ignorant application" fallacy, assuming that th=
e
> policy takes care of everything so that the application doesn't have
> to do anything. This never worked in the bad old days of Unix based
> MLS systems, and as you point out, it still does not work today.

I should have written that point better.  Application developers have
to build for all systems.  They have to build configurations for the
multitude of SELinux systems out there that are incompatible then
system might be running Smack or other LSM so then they have to build
configuration files for them.  So it ends up too complex more files
they have to maintain bigger risk of sink errors between the files.
>
>> Remember safety systems can kill just as much save. =A0In this case =
we
>> as a kernel could be prosecuted for a too complex interface to
>> secuirty system when a simpler could be done to achieve the same lev=
el
>> of secuirty. =A0There have been cases where companys who have put to=
o
>> complex of secuirty on devices have been sued and lost. =A0Due to th=
e
>> fact it too so long to start up a machine to move weight off a perso=
n
>> that they died from crushing.
>>
>
> Amen brother. Simple good. Sophisticated bad.

Too simple is bad as well.  Its key to make sure complexity is
manageable.  Sophisticated and Simple are not against each other.

Something can be extremely simple to use but performing extremely
Sophisticated operations.   The key thing to make a Sophisticated
Simple is breaking design into manageable parts.

Past you have just taken make design simpler cut out the Sophisticated
parts so making a weaker system.

A embroidery machine is insanely Sophisticated.  The hardware side is
hidden from users.  Mechanics working on the machine worry about that
part.   The designer worries about the designs stitches and the like
while not worrying about the hardware.  The operate of the machine
just make sure they feed the matterial for the embroidery in and press
the right button for the right design.

Now lets say we took that same Sophisticated machine and made creating
the design and the hardware side 1.  Straight away a machine that was
perfectly simple for a designer to put in a new pattern becomes
insanely complex.   They were split in 2 for a good reason.

Is there any good reason to keep application and user related secuirty
data in the same file or even the same format.  There is no good
reason if it just making a Sophisticated problem more complex than it
should be.

Note Mechanices and designers work in 2 completely different formats
in embroidery machines and they get along perfectly.

A generic format the designer produces when in-loading into machine
its converted to the machines internal format.  Even printing is the
same with PDF.  Every printing press design is different but you can
send the same documents to them all.  Makes life simpler.   We need
the same for application secuirty data.

Please don't think  Sophisticated equals complex for user any more.  I
can keep on providing examples after examples that its wrong.
Sophisticated to create yes.  But should not equal complex to use.
>
>> Currently Application Developers are being crushed under too large o=
f
>> problem so they are responding with the only valid path remove the
>> defective secuirty.
>>
>> Basically the One size fits all is the problem. =A0We currently have=
 a
>> shoe that fits no one well. =A0 We need 2 shoes one for the applicat=
ion
>> developer(Generic LSM interface for applications) one for the
>> administrators(Very much the current LSM system cleaned up) that fit=
s
>> over the same socks(Linux) no problems.
>>
>
> Yes. One size fits all is bad. No, generic interfaces to disparate
> mechanisms are not good. I hate to say this, but you can't have what
> you're requesting. It does not make sense.

Generic interfaces covering what will always been the same is good.
It prevents unrequired duplication.
>
>> Please don't over look Alan Cox that items like Selinux are spreadin=
g
>> arms out in stuff like postgresql and X11. =A0These interfaces reall=
y
>> should have been generic interfaces or the same crap of duplication
>> you are fighting against in kernel is going to happen every where el=
se
>> in Userspace.
>>
>
> It's already started. Sorry.

So adding on a framework for generic controls of LSM does go hand in
hand with this.  Other wise threads that should have been lowed in
privilege are not.
>
>> The compete user-space application side interfaces for LSM has been
>> baddy neglected. =A0It seams to be the idea that Applications have n=
o
>> right to talk to LSM becuase that way everything will be more secure=
=2E
>> =A0LSM with application control can run finer secuirty than LSM with=
out
>> application control. =A0 Reason application know what it is doing in
>> each thread so can tell LSM to disable what is not need in that thre=
ad
>> so reducing attack points to get access where the LSM without
>> application control has to provide an access rights over the complet=
e
>> applications.
>>
>> Basically current model is defective secuirty. =A0 So we have comple=
x
>> hard to use secuirty that does not work as good as what it could. =A0=
No
>> wonder application developers are disabling it. =A0 We should be mor=
e
>> serious about addressing the problem.
>>
>
> If you want to get away from complexity you can start by eschewing
> SELinux. SELinux is designed to encompass absolutely everything and
> hence must be too complex. Look elsewhere and look carefully before
> you blame the underlying mechanisms.
>
You don't get it I am not just talking about SELinux.  I am talking
about the complete LSM model from the application builder point of
view.   There is no central data store for application stuff.

Application and user control policies are different.  Current LSM
model shoves both into the same area.  So making it extremely hard to
sort out what was a admin alteration to allow user to do something and
what is required by application.   This is a very big design problem.

Peter Dolding
