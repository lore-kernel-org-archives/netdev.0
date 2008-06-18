From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs
	Documentation
Date: Wed, 18 Jun 2008 14:38:00 +0200
Message-ID: <485901A8.8060705@trash.net>
References: <20080610205633.11186.45499.stgit@dale>	
	<20080610210918.11186.64253.stgit@dale>
	<484F751F.7030407@trash.net>	
	<c8028d330806120813q6363c3cemb4aa03ceff6547d1@mail.gmail.com>	
	<48513E4E.4040601@trash.net>	
	<f8ca0a150806141103r56f0530br6b5e78943ac1c92d@mail.gmail.com>	
	<20080614190358.GU22807@obsidianresearch.com>	
	<48562A41.7000304@trash.net>
	<71d336490806180532g4ea7067akc157581cb1fa946d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>, netdev@vger.kernel.org,
	rdreier@cisco.com, general@lists.openfabrics.org,
	poornima.kamath@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <71d336490806180532g4ea7067akc157581cb1fa946d@mail.gmail.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Ramachandra K wrote:
> Is your suggestion that the netdevice needs to be registered as soon
> as we get parameters from userspace even if that netdevice stays
> inactive until we finish all of our communication with the QLogic EVIC
> gateway device over the IB network ?

Yes, it should be created as soon as the administrator
issues the command to do so.

> Currently we register netdevice only after we have made sure that we
> can connect to the EVIC and that there are enough resources on the
> EVIC to support this virtual ethernet interface. But if we register
> the netdevice
> without making sure that we can reach the EVIC and that it has resources,
> there is a possibility that we register a netdevice that can never
> become active.

Thats similar to a ethernet device that never has a cable
plugged in. You should register the device with its carrier
turned off, then change the carrier state once the connection
has been established.

> Isn't our current behavior analogous to an ethernet driver not
> registering a netdev if it
> can't properly initialize its hardware ?

No, hardware probing is done automatically, while with your
device the administrator explicitly asks to create the device.
The expected behaviour is that the device exists once the
command finishes without returning an error.
