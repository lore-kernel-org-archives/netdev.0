From: Roland Dreier <roland.dreier@gmail.com>
Subject: Re: [PATCH] PCI: Update ACS quirk for more Intel 10G NICs
Date: Mon, 24 Jul 2017 12:31:39 -0700
Message-ID: <CAG4TOxOFVctaGOk=bHo8XZ+Nw4mr_qM+XbhBO2=zPn3uKY-gkg@mail.gmail.com>
References: <20170720214101.7449-1-roland@kernel.org> <20170720161554.45ce1673@ul30vt.home>
 <CAG4TOxOrF9aLyujrwNmSsxPBWBPTaLx2yXkOJ88gxCj0QUGDow@mail.gmail.com>
 <20170724104505.74c67861@w520.home> <CAG4TOxNufQHj0nNwzw_yDMQfp+cAQuiQgEJg6KNX2ebiJDUuUw@mail.gmail.com>
 <20170724130159.309379e8@w520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Emil Tantilov <emil.s.tantilov@intel.com>
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170724130159.309379e8@w520.home>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Is there a misunderstanding of the code flow here?  We're never setting
> EC.  In the first code block we're just masking out requested
> capabilities where unimplemented capabilities is the same as
> implemented + enabled.  We're not adding EC to the request, we're
> just not removing it based on the implemented capabilities because we
> don't interpret it the same way.  Thus if someone wants to test a
> device for EC, it really needs to implement EC, we cannot assume it
> based on lack of support for EC in the ACS capability.  As you point
> out, nobody really cares about EC yet though.

I guess I find the semantics confusing.  For every other bit,
pci_acs_enabled() returns true if the bit is either enabled or not
implemented.  For EC, it returns false if the bit is not implemented.

It's not clear to me what the use case for checking for PCI_ACS_EC
enabled would be.  Seems like checking for EC in the capabilities
register would be more useful.

 - R.
